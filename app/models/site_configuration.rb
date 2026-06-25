class SiteConfiguration < ApplicationRecord
  belongs_to :site

  has_one_attached :hero_image
  has_one_attached :logo_image
  has_one_attached :team_photo
  has_many_attached :gallery_images

  after_commit :compress_logo_if_oversize, if: -> { logo_image.attached? }

  validates :business_name, presence: true
  validate :acceptable_images

  def services_array
    services_list.is_a?(Array) ? services_list : []
  end

  def faqs_array
    faqs.is_a?(Array) ? faqs : []
  end

  private

  def acceptable_images
    if logo_image.attached?
      unless logo_image.content_type.in?(%w[image/jpeg image/png image/webp image/svg+xml])
        errors.add(:logo_image, "must be a JPEG, PNG, WebP, or SVG")
      end
    end

    if hero_image.attached?
      unless hero_image.content_type.in?(%w[image/jpeg image/png image/webp image/gif])
        errors.add(:hero_image, "must be a JPEG, PNG, WebP, or GIF")
      end
      if hero_image.byte_size > 5.megabytes
        errors.add(:hero_image, "must be less than 5MB")
      end
    end

    if team_photo.attached?
      unless team_photo.content_type.in?(%w[image/jpeg image/png image/webp])
        errors.add(:team_photo, "must be a JPEG, PNG, or WebP")
      end
      if team_photo.byte_size > 5.megabytes
        errors.add(:team_photo, "must be less than 5MB")
      end
    end

    gallery_images.each do |img|
      unless img.content_type.in?(%w[image/jpeg image/png image/webp image/gif])
        errors.add(:gallery_images, "must be JPEG, PNG, WebP, or GIF files")
        break
      end
      if img.byte_size > 5.megabytes
        errors.add(:gallery_images, "each file must be less than 5MB")
        break
      end
    end
  end

  def compress_logo_if_oversize
    return unless logo_image.blob.byte_size > 2.megabytes
    return if logo_image.content_type == "image/svg+xml"

    # Use chunky_png for PNG files (pure Ruby, no native dependencies)
    if logo_image.content_type == "image/png"
      compress_png_with_chunky
    else
      # For JPEG/WebP, try image_processing if available, otherwise skip
      compress_with_image_processing
    end
  rescue StandardError => e
    Rails.logger.warn "Logo compression skipped: #{e.message}"
  end

  def compress_png_with_chunky
    require "chunky_png"

    logo_image.blob.open do |tempfile|
      image = ChunkyPNG::Image.from_file(tempfile.path)

      # First pass: resize to 560x160 max
      image = resize_image(image, 560, 160)
      compressed = compress_to_tempfile(image, 80)

      # Second pass: if still over 2MB, try smaller size
      if File.size(compressed.path) > 2.megabytes
        image = resize_image(image, 420, 120)
        compressed = compress_to_tempfile(image, 60)
      end

      # Replace the attachment
      logo_image.attach(
        io: File.open(compressed.path),
        filename: "#{File.basename(logo_image.filename.to_s, '.*')}.png",
        content_type: "image/png"
      )
    end
  end

  def compress_with_image_processing
    processor = image_processor_available
    return unless processor

    logo_image.blob.open do |tempfile|
      result = processor
        .source(tempfile.path)
        .resize_to_limit(560, 160)
        .convert("webp")
        .saver(quality: 80)
        .call

      if File.size(result.path) > 2.megabytes
        result = processor
          .source(tempfile.path)
          .resize_to_limit(420, 120)
          .convert("webp")
          .saver(quality: 60)
          .call
      end

      logo_image.attach(
        io: File.open(result.path),
        filename: "#{File.basename(logo_image.filename.to_s, '.*')}.webp",
        content_type: "image/webp"
      )
    end
  end

  def resize_image(image, max_width, max_height)
    current_width = image.width
    current_height = image.height

    if current_width <= max_width && current_height <= max_height
      return image
    end

    # Calculate aspect ratio
    ratio = [max_width.to_f / current_width, max_height.to_f / current_height].min
    new_width = (current_width * ratio).to_i
    new_height = (current_height * ratio).to_i

    image.resize(new_width, height: new_height)
  end

  def compress_to_tempfile(image, quality)
    # chunky_png doesn't have quality control, so we just save as-is
    # The size reduction comes from the resize
    tempfile = Tempfile.new(["logo_compressed", ".png"])
    image.save(tempfile.path)
    tempfile
  end

  def image_processor_available
    ImageProcessing::Vips
  rescue LoadError
    begin
      ImageProcessing::MiniMagick
    rescue LoadError
      nil
    end
  end
end

class SiteConfiguration < ApplicationRecord
  belongs_to :site

  has_one_attached :hero_image
  has_one_attached :logo_image
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

    processor = image_processor_available
    return unless processor

    # Progressively reduce quality/size until under 2MB
    processed = logo_image.blob.open do |tempfile|
      result = processor
        .source(tempfile.path)
        .resize_to_limit(560, 160)
        .convert("webp")
        .saver(quality: 80)
        .call

      # If still over 2MB, try lower quality
      if File.size(result.path) > 2.megabytes
        result = processor
          .source(tempfile.path)
          .resize_to_limit(420, 120)
          .convert("webp")
          .saver(quality: 60)
          .call
      end

      result
    end

    logo_image.attach(
      io: File.open(processed.path),
      filename: "#{File.basename(logo_image.filename.to_s, '.*')}.webp",
      content_type: "image/webp"
    )
  rescue LoadError, StandardError => e
    Rails.logger.warn "Logo compression skipped: #{e.message}"
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

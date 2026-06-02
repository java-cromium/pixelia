class SiteConfiguration < ApplicationRecord
  belongs_to :site

  has_one_attached :hero_image
  has_many_attached :gallery_images

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
end

class Page < ApplicationRecord
  belongs_to :site

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: { scope: :site_id }
  validates :status, inclusion: { in: %w[draft published] }

  scope :published, -> { where(status: "published") }
  scope :ordered, -> { order(:position, :title) }

  before_validation :generate_slug, if: -> { slug.blank? && title.present? }

  def publish!
    update!(status: "published")
  end

  def draft!
    update!(status: "draft")
  end

  private

  def generate_slug
    self.slug = title.parameterize
  end
end

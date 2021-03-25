class Micropost < ApplicationRecord
  belongs_to :user
  # 一つの投稿に一つの画像/動画を添付できる
  has_one_attached :image
    default_scope -> { self.order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image, content_type: { in: %w[image/jpeg image/gif image/png],
                                    message: "must be a valid image format (jpeg/gif/png)" },
                    size: { less_than: 1.megabytes, message: "should be less than 1MB" }
  
  def display_image
    image.variant(resize_to_limit: [500, 500])
  end
end

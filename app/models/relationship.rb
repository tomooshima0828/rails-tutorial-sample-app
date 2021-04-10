class Relationship < ApplicationRecord
  # 規約: "モデル名_id"なので、"follower_id"となってしまうので、class_name: "User"と明示する
  belongs_to :follower, class_name: "User"
  # 規約: "モデル名_id"なので、"followed_id"となってしまうので、class_name: "User"と明示する
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true


end
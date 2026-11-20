class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :post

  enum :stamp, { thumbs_up: 0 }, validate: true

  # user_id-post_id-stampの種類の3つの組み合わせがユニークであること=「一人一投稿1スタンプにつき1回まで」
  validates :user_id, uniqueness: { scope: [ :post_id, :stamp ] }
end

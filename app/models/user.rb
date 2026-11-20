class User < ApplicationRecord
  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members
  has_many :posts, dependent: :restrict_with_error   # 退会機能を作るときに再検討（一旦、投稿のあるユーザーは削除できない）
  has_many :reactions, dependent: :destroy
  devise :database_authenticatable, :registerable, :validatable

  validates :name, presence: true, length: { maximum: 20 }
end

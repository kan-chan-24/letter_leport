class User < ApplicationRecord
  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members
  devise :database_authenticatable, :registerable, :validatable

  validates :name, presence: true, length: { maximum: 20 }
end

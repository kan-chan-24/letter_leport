class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable

  validates :name, presence: true, length: { maximum: 20 }
end

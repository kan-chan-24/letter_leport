class TimelinePeriod < ApplicationRecord
  belongs_to :group
  has_many :posts, dependent: :destroy

  validates :started_at, presence: true
  validates :ended_at, presence: true
end

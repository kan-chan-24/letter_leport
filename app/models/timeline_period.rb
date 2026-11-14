class TimelinePeriod < ApplicationRecord
  belongs_to :group

  validates :started_at, presence: true
  validates :ended_at, presence: true
end

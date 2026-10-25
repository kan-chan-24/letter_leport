class Group < ApplicationRecord
  has_many :group_members, dependent: :destroy
  has_many :users, through: :group_members

  has_secure_token :invite_token, on: :initialize
  
  enum :interval_unit, { week: 0, month: 1}

  validates :name, presence: true
  validates :invite_token, presence: true, uniqueness: true
  validates :interval_unit, presence: true
  validates :interval_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: :max_interval_count }
  validates :notify_day_of_week, presence: true, numericality: { only_integer: true, in: 0..6 }
  validates :notify_day_of_month, presence: true, numericality: { only_integer: true, in: 1..28 }
  validates :notify_hour, presence: true, numericality: { only_integer: true, in: 0..23 }
  validates :next_notify_at, presence: true

  private

  def max_interval_count
    week? ? 8 : 12
  end
end

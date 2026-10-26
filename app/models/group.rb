class Group < ApplicationRecord
  has_many :group_members, dependent: :destroy
  has_many :users, through: :group_members

  has_secure_token :invite_token, on: :initialize

  enum :interval_unit, { week: 0, month: 1 }

  # 通知頻度プリセット用の定数（週１〜年１まで）
  FREQUENCY_PRESET = {
    one_week: { interval_unit: "week", interval_count: 1, label: "週1回" },
    one_month: { interval_unit: "month", interval_count: 1, label: "月1回" },
    three_month: { interval_unit: "month", interval_count: 3, label: "3ヶ月に1回" },
    six_month: { interval_unit: "month", interval_count: 6, label: "半年に1回" },
    one_year: { interval_unit: "month", interval_count: 12, label: "年1回" }
  }.freeze

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

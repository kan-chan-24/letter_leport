class Post < ApplicationRecord
  belongs_to :user
  belongs_to :group
  belongs_to :timeline_period

  validates :physical_condition, :daily_condition, :fun_condition,
            presence: true,
            inclusion: { in: 1..5, allow_nil: true }

  validates :user_id, uniqueness: { scope: :timeline_period_id }
  validates :content, length: { maximum: 500 }
end

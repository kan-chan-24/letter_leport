class Post < ApplicationRecord
  belongs_to :user
  belongs_to :group
  belongs_to :timeline_period

  # 3つの調子の入力を必須。入力範囲を1~5の間にする
  validates :physical_condition, :daily_condition, :fun_condition,
            presence: true,
            inclusion: { in: 1..5, allow_nil: true }

  # 複合ユニーク制約で、一期間一投稿に制限
  validates :user_id, uniqueness: { scope: :timeline_period_id }
  # 自由入力欄は500文字で制限（要調整）
  validates :content, length: { maximum: 500 }
end

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

  # 文字数制限の定数
  CONTENT_MAX_LENGTH = 500
  # 自由入力欄の文字数を制限
  validates :content, length: { maximum: CONTENT_MAX_LENGTH }

  # 調子の定数
  CONDITION_ITEMS = [
    {
      attr: :physical_condition, title: "からだの調子", sub: "睡眠・体調・エネルギー", icon: "💪",
      options: { 1 => "休養中 💤", 2 => "省エネ中 🍵", 3 => "ふつう ⛅", 4 => "軽やか 🌿", 5 => "とても快調 🌱" }
    },
    {
      attr: :daily_condition, title: "日々のこと", sub: "仕事・家事・ペース", icon: "☀️",
      options: { 1 => "手一杯 🌀", 2 => "バタバタ 🏃", 3 => "いつも通り ☕", 4 => "順調 ⛵", 5 => "絶好調 🚀" }
    },
    {
      attr: :fun_condition, title: "たのしみ", sub: "趣味・散歩・息抜き", icon: "🎨",
      options: { 1 => "後まわし 🍂", 2 => "少しだけ 📖", 3 => "ほどほど 🎧", 4 => "充実してる 🎨", 5 => "最高 ✨" }
    }
  ].freeze
end

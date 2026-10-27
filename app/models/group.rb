class Group < ApplicationRecord
  has_many :group_members, dependent: :destroy
  has_many :users, through: :group_members

  has_secure_token :invite_token, on: :initialize

  enum :interval_unit, { week: 0, month: 1 }

  # DBには保存しない「仮想属性」。フォームから届く通知頻度を受け取るためのもの
  attribute :frequency, :string

  # 通知頻度プリセット用の定数（週１〜年１まで）
  FREQUENCY_PRESET = {
    one_week: { interval_unit: "week", interval_count: 1, label: "週1回" },
    one_month: { interval_unit: "month", interval_count: 1, label: "月1回" },
    three_month: { interval_unit: "month", interval_count: 3, label: "3ヶ月に1回" },
    six_month: { interval_unit: "month", interval_count: 6, label: "半年に1回" },
    one_year: { interval_unit: "month", interval_count: 12, label: "年1回" }
  }.freeze

  # バリデーションの直前に、frequency を interval_unit などに変換する（空チェック前に値を入れておきたい）
  before_validation :apply_frequency_preset, on: :create

  validates :name, presence: true
  validates :invite_token, presence: true, uniqueness: true
  validates :frequency, inclusion: { in: FREQUENCY_PRESET.keys.map(&:to_s), message: "を選択してください" }, on: :create
  validates :interval_unit, presence: true
  validates :interval_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: :max_interval_count }
  validates :notify_day_of_week, presence: true, numericality: { only_integer: true, in: 0..6 }
  validates :notify_day_of_month, presence: true, numericality: { only_integer: true, in: 1..28 }
  validates :notify_hour, presence: true, numericality: { only_integer: true, in: 0..23 }
  validates :next_notify_at, presence: true

  # 保存済みの interval_unit・interval_count から、表示用のラベル（例: "半年に1回"）を返す
  def frequency_label
    preset = FREQUENCY_PRESET.values.find do |p|
      p[:interval_unit] == interval_unit && p[:interval_count] == interval_count
    end
    preset&.dig(:label)
  end

  private

  def max_interval_count
    week? ? 8 : 12
  end

  # frequency（例: "six_month"）をもとに、保存用カラムの値をセットする
  def apply_frequency_preset
    preset = FREQUENCY_PRESET[frequency&.to_sym]
    return if preset.nil?

    self.interval_unit  = preset[:interval_unit]
    self.interval_count = preset[:interval_count]

    self.next_notify_at = NotifyAtCalculator.first_notify_at(
      base_time: Time.current,
      interval_unit: interval_unit,
      notify_day_of_week: notify_day_of_week,
      notify_day_of_month: notify_day_of_month,
      notify_hour: notify_hour
    )
  end
end

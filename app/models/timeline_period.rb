class TimelinePeriod < ApplicationRecord
  belongs_to :group
  has_many :posts, dependent: :destroy

  validates :started_at, presence: true
  validates :ended_at, presence: true

  # 期間の投稿の中で、特定のユーザーの投稿が存在するかをチェック（期間内の投稿済チェック）
  def posted_by?(user)
    posts.exists?(user: user)
  end

  # 現在の期間が有効かどうか（現在時刻より過ぎているなら無効扱い）
  def active?
    ended_at > Time.current
  end

  # TLの見出し用ラベル算出メソッド（例: "11月4週目" / "11月" / "11月〜1月"）
  def heading_label
    # 計算の基準になる、期間の開始日を記録
    start_on = started_at.to_date

    # 単位が週の場合："11月4週目"と出す。週数は開始日の曜日が、現在日で今月何回目かで算出
    if group.interval_unit == "week"
      "#{start_on.month}月#{(start_on.day - 1) / 7 + 1}週目"
    # 月単位で、月に一回なら現在の月をそのまま"11月"と表示
    elsif group.interval_count == 1
      "#{start_on.month}月"
    # 頻度が2ヶ月以上の場合は"11月~1月"のように表示
    else
      # 3ヶ月なら開始月を含めて3ヶ月分なので、足すのは (3 - 1) ヶ月
      last_month = (start_on + (group.interval_count - 1).months).month
      "#{start_on.month}月〜#{last_month}月"
    end
  end
end

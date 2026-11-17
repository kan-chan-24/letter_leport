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
end

class GroupMember < ApplicationRecord
  belongs_to :group
  belongs_to :user

  enum :role, { host: 0, member: 1 }, validate: true

  # グループメンバー表で同じ組み合わせが重複しない（二重登録を防ぐ）
  validates :user_id, uniqueness: { scope: :group_id }
end

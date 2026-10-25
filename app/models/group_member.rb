class GroupMember < ApplicationRecord
  belongs_to :group
  belongs_to :user

  enum :role, { host: 0, member: 1 }, validate: true

  validates :user_id, uniqueness: { scope: :group_id }
end

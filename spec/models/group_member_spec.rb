require "rails_helper"

RSpec.describe GroupMember, type: :model do
  let(:group) { create(:group) }
  let(:user) { create(:user) }

  describe "二重参加の防止" do
    before do
      # 先に1回参加しておく
      create(:group_member, group: group, user: user)
    end

    it "同じユーザーが同じグループに二重で参加できない" do
      duplicate = build(:group_member, group: group, user: user)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end

    it "同じユーザーでも、別のグループには参加できる" do
      other_group = create(:group)
      member = build(:group_member, group: other_group, user: user)

      expect(member).to be_valid
    end

    it "同じグループでも、別のユーザーは参加できる" do
      other_user = create(:user)
      member = build(:group_member, group: group, user: other_user)

      expect(member).to be_valid
    end
  end
end

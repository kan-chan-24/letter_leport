require 'rails_helper'

RSpec.describe "GroupMembers", type: :request do
  describe "POST /invitations/:invitation_token/group_members" do
    let!(:group) { create(:group) }
    let(:user) { create(:user) }

    context "ログイン中・未参加の場合" do
      before { sign_in user }

      it "グループメンバーが1人追加される" do
        expect {
          post invitation_group_members_path(group.invite_token)
        }.to change(GroupMember, :count).by(1)
      end

      it "グループのTL画面へリダイレクトされる" do
        post invitation_group_members_path(group.invite_token)
        expect(response).to redirect_to(group_path(group))
      end
    end
  end
end

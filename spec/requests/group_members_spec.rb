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

  describe "DELETE /groups/:group_id/group_members/:id" do
    let!(:group) { create(:group) }
    let(:host_user) { create(:user) }
    let(:member_user) { create(:user) }
    let!(:host_member) { create(:group_member, group: group, user: host_user, role: :host) }
    let!(:target_member) { create(:group_member, group: group, user: member_user, role: :member) }

    context "ホストがメンバーを外す場合" do
      before { sign_in host_user }

      it "グループメンバーが1人削除される" do
        expect {
          delete group_group_member_path(group, target_member)
        }.to change(GroupMember, :count).by(-1)
      end

      it "グループ設定画面へリダイレクトされる" do
        delete group_group_member_path(group, target_member)
        expect(response).to redirect_to(edit_group_path(group))
      end
    end

    context "ホスト以外が外そうとする場合" do
      let(:other_user) { create(:user) }
      let!(:other_member) { create(:group_member, group: group, user: other_user, role: :member) }

      before { sign_in other_user }

      it "グループメンバーが削除されない" do
        expect {
          delete group_group_member_path(group, target_member)
        }.not_to change(GroupMember, :count)
      end

      it "グループのTL画面へリダイレクトされる" do
        delete group_group_member_path(group, target_member)
        expect(response).to redirect_to(group_path(group))
      end
    end

    context "ホストが自分を外そうとする場合" do
      before { sign_in host_user }

      it "グループメンバーが削除されない" do
        expect {
          delete group_group_member_path(group, host_member)
        }.not_to change(GroupMember, :count)
      end

      it "グループ設定画面へリダイレクトされる" do
        delete group_group_member_path(group, host_member)
        expect(response).to redirect_to(edit_group_path(group))
      end
    end
  end
end

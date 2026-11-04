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

      it "追加されたメンバーのroleがmemberになる" do
        post invitation_group_members_path(group.invite_token)

        expect(group.group_members.find_by(user: user)).to be_member
      end

      it "グループのTL画面へリダイレクトされる" do
        post invitation_group_members_path(group.invite_token)

        expect(response).to redirect_to(group_path(group))
      end

      it "参加メッセージが表示される" do
        post invitation_group_members_path(group.invite_token)

        expect(flash[:notice]).to eq "#{group.name}に参加しました"
      end
    end

    context "ログイン中・参加済みの場合" do
      before do
        create(:group_member, group: group, user: user)
        sign_in user
      end

      it "グループメンバーが増えない" do
        expect {
          post invitation_group_members_path(group.invite_token)
        }.not_to change(GroupMember, :count)
      end

      it "グループのTL画面へリダイレクトされる" do
        post invitation_group_members_path(group.invite_token)

        expect(response).to redirect_to(group_path(group))
      end

      it "参加メッセージが表示されない" do
        post invitation_group_members_path(group.invite_token)

        expect(flash[:notice]).to be_nil
      end
    end

    context "未ログインの場合" do
      it "グループメンバーが増えない" do
        expect {
          post invitation_group_members_path(group.invite_token)
        }.not_to change(GroupMember, :count)
      end

      it "ログイン画面へリダイレクトされる" do
        post invitation_group_members_path(group.invite_token)

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン中・トークンが無効な場合" do
      before { sign_in user }

      it "グループメンバーが増えない" do
        expect {
          post invitation_group_members_path("invalid_token")
        }.not_to change(GroupMember, :count)
      end

      it "404を返す" do
        post invitation_group_members_path("invalid_token")

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

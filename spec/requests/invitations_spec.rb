require 'rails_helper'

RSpec.describe "Invitations", type: :request do
  describe "GET /invitations/:token" do
    let(:group) { create(:group) }
    let(:member) { create(:user) }

    before do
      create(:group_member, group: group, user: member)
    end

    context "有効なトークンの場合" do
      before { get invitation_path(group.invite_token) }

      it "招待ページが表示される" do
        expect(response).to have_http_status(:ok)
      end

      it "グループ名とメンバー名が表示される" do
        expect(response.body).to include(group.name)
        expect(response.body).to include(member.name)
      end

      it "未ログインなら、登録・ログインのボタンが表示される" do
        expect(response.body).to include("新規登録して参加")
        expect(response.body).to include("ログインして参加")
      end

      it "未ログインなら、トークンがセッションに保存される" do
        expect(session[:invitation_token]).to eq(group.invite_token)
      end
    end

    context "無効なトークンの場合" do
      before { get invitation_path("invalid_token") }

      it "404が返り、無効ページが表示される" do
        expect(response).to have_http_status(:not_found)
        expect(response.body).to include("このリンクは無効です")
      end

      it "グループ情報は表示されない" do
        expect(response.body).not_to include(group.name)
      end
    end
  end
end

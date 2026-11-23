require "rails_helper"

RSpec.describe "Mypages", type: :request do
  describe "GET /mypage" do
    let(:user) { create(:user) }

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get mypage_path
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "参加しているグループがない場合" do
        it "グループ作成の案内が表示される" do
          get mypage_path
          expect(response.body).to include "参加しているグループがありません"
        end
      end

      context "グループに参加していて、投稿がない場合" do
        let(:group) { create(:group) }
        let!(:group_member) { create(:group_member, group: group, user: user) }
        
        it "投稿をしていない案内が表示される" do
          get mypage_path
          expect(response.body).to include "まだ近況は知らせていません"
        end
      end

      context "投稿がある場合" do
        let(:group) { create(:group) }

        it "自分の投稿がグループ名つきで表示される"
        
        it "他人の投稿は表示されない"

        it "空の案内は表示されない"
      end
    end
  end
end
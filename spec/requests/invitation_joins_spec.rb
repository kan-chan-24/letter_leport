require "rails_helper"

RSpec.describe "未ログインからの招待参加", type: :request do
  # 招待先のグループを用意する
  let(:group) { create(:group) }

  # 新規登録フォームから送る値
  let(:sign_up_params) do
    {
      user: {
        name: "招待 太郎",
        email: "invited@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }
  end

  describe "新規登録" do
    context "招待ページを開いたあとの場合" do
      # 招待ページを開き、トークンをセッションに保存する
      before { get invitation_path(group.invite_token) }

      it "グループのメンバーが1人増える" do
        expect {
          post user_registration_path, params: sign_up_params
        }.to change { group.group_members.count }.by(1)
      end

      it "TL画面に移動し、参加メッセージをセットする" do
        post user_registration_path, params: sign_up_params

        expect(response).to redirect_to(group_path(group))
        expect(flash[:notice]).to eq("#{group.name}に参加しました")
      end
    end

    context "招待ページを開いていない場合" do
      it "個人ページに移動し、新規登録メッセージをセットする" do
        post user_registration_path, params: sign_up_params

        expect(response).to redirect_to(mypage_path)
        expect(flash[:notice]).to eq(I18n.t("devise.registrations.signed_up"))
      end
    end
  end

  describe "ログイン" do
    # ログインするユーザーを、グループに未参加の状態で用意する
    let!(:user) { create(:user, password: "password") }

    # ログインフォームから送る値
    let(:sign_in_params) do
      {
        user: {
          email: user.email,
          password: "password"
        }
      }
    end

    context "招待ページを開いたあとの場合" do
      # 招待ページを開き、トークンをセッションに保存する
      before { get invitation_path(group.invite_token) }

      it "グループのメンバーが1人増える" do
        expect {
          post user_session_path, params: sign_in_params
        }.to change { group.group_members.count }.by(1)
      end

      it "TL画面に移動し、参加メッセージをセットする" do
        post user_session_path, params: sign_in_params

        expect(response).to redirect_to(group_path(group))
        expect(flash[:notice]).to eq("#{group.name}に参加しました")
      end

      it "参加後、セッションから招待トークンを削除する" do
        # ログイン前はトークンが保存されている
        expect(session[:invite_token]).to eq(group.invite_token)
        # ログイン
        post user_session_path, params: sign_in_params

        # ログイン後はトークンが消えている
        expect(session[:invite_token]).to be_nil
      end
    end

    context "招待ページを開いていない場合" do
      it "個人ページに移動し、ログインメッセージをセットする" do
        post user_session_path, params: sign_in_params

        expect(response).to redirect_to(mypage_path)
        expect(flash[:notice]).to eq(I18n.t("devise.sessions.signed_in"))
      end
    end
  end

  describe "参加済みユーザーのログイン" do
    # ログインするユーザーを用意する
    let!(:user) { create(:user, password: "password") }

    # ログインフォームから送る値
    let(:sign_in_params) do
      {
        user: {
          email: user.email,
          password: "password"
        }
      }
    end

    context "招待ページを開いたあとの場合" do
      before do
        # ユーザーを先にグループのメンバーにしておく
        group.add_member(user)
        # 招待ページを開き、トークンをセッションに保存する
        get invitation_path(group.invite_token)
      end

      it "グループのメンバーが増えない" do
        expect {
          post user_session_path, params: sign_in_params
        }.not_to change { group.group_members.count }
      end

      it "TL画面に移動し、ログインメッセージをセットする" do
        post user_session_path, params: sign_in_params

        expect(response).to redirect_to(group_path(group))
        expect(flash[:notice]).to eq(I18n.t("devise.sessions.signed_in"))
      end
    end
  end
end

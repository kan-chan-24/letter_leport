# spec/requests/group_settings_spec.rb
require "rails_helper"

RSpec.describe "グループ設定", type: :request do
  let(:host_user) { create(:user) }
  let(:member_user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:group) { create(:group, name: "変更前の名前") }

  before do
    create(:group_member, group: group, user: host_user, role: :host)
    create(:group_member, group: group, user: member_user, role: :member)
  end

  describe "GET /groups/:id/edit" do
    it "ホストは設定画面を開ける" do
      sign_in host_user
      get edit_group_path(group)

      expect(response).to have_http_status(:ok)
    end

    it "ホスト以外のメンバーはTL画面へ移動する" do
      sign_in member_user
      get edit_group_path(group)

      expect(response).to redirect_to(group_path(group))
    end

    it "グループに参加していないユーザーはマイページへ移動する" do
      sign_in other_user
      get edit_group_path(group)

      expect(response).to redirect_to(mypage_path)
    end
  end

  describe "PATCH /groups/:id" do
    it "ホストはグループ名を変更できる" do
      sign_in host_user
      patch group_path(group), params: { group: { name: "変更後の名前" } }

      expect(response).to redirect_to(edit_group_path(group))
      expect(group.reload.name).to eq("変更後の名前")

      follow_redirect!
      expect(response.body).to include("設定を保存しました")
    end

    it "グループ名が空なら保存せず、エラーを返す" do
      sign_in host_user
      patch group_path(group), params: { group: { name: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(group.reload.name).to eq("変更前の名前")
    end

    it "ホスト以外のメンバーはグループ名を変更できない" do
      sign_in member_user
      patch group_path(group), params: { group: { name: "変更後の名前" } }

      expect(response).to redirect_to(group_path(group))
      expect(group.reload.name).to eq("変更前の名前")
    end
  end

  describe "TL画面のグループ設定ボタン" do
    it "ホストには表示される" do
      sign_in host_user
      get group_path(group)

      expect(response.body).to include(edit_group_path(group))
    end

    it "ホスト以外のメンバーには表示されない" do
      sign_in member_user
      get group_path(group)

      expect(response.body).not_to include(edit_group_path(group))
    end
  end
end

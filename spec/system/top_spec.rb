require "rails_helper"

RSpec.describe "TOPページ", type: :system do
  it "ログインリンクからログイン画面へ移動できる" do
    visit root_path                  # TOPページを開く
    click_link "ログインはこちら"     # リンクの文字で探してクリック
    expect(page).to have_current_path new_user_session_path  # ログイン画面のURLになっているか
  end
end
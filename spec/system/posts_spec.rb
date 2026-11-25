require "rails_helper"

RSpec.describe "近況投稿の流れ", type: :system do
  let(:user) { create(:user) }
  let(:group) { create(:group, name: "家族グループ") }
  let!(:membership) { create(:group_member, group: group, user: user) }
  let!(:period) do
    # request specと同じ形：今の期間がなければ作る
    group.current_period || create(:timeline_period, group: group, started_at: 1.day.ago, ended_at: 1.week.from_now)
  end

  it "ログインして投稿し、TLに表示され、編集できる" do
    # --- ログイン ---
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: user.password
    click_button "ログイン"

    # --- TLから投稿画面へ ---
    visit group_path(group)
    click_link "近況を書き始める"
    expect(page).to have_content "近況を書く"

    # --- 3項目を選んで投稿 ---
    choose "軽やか"       # からだの調子：4
    choose "いつも通り"   # 日々のこと：3
    choose "最高"         # たのしみ：5
    fill_in "最近のできごと", with: "近所の桜が咲きました"
    click_button "近況を届ける"

    # --- TLに表示される ---
    expect(page).to have_current_path group_path(group)
    expect(page).to have_content "近況を知らせました"
    expect(page).to have_content "近所の桜が咲きました"
    expect(page).to have_content "今回の近況は届けました"

    # --- 編集 ---
    click_link "投稿の編集"
    expect(page).to have_content "近況を編集する"
    fill_in "最近のできごと", with: "桜が満開になりました"
    click_button "更新する"

    # --- 編集内容がTLに反映される ---
    expect(page).to have_current_path group_path(group)
    expect(page).to have_content "近況を更新しました"
    expect(page).to have_content "桜が満開になりました"
    expect(page).not_to have_content "近所の桜が咲きました"
  end
end
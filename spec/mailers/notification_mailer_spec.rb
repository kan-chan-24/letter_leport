require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  describe "#report_reminder" do
    let(:user)  { create(:user) }
    let(:group) { create(:group, name: "家族") }
    let(:mail)  { NotificationMailer.with(user: user, group: group).report_reminder }

    # 「○月○週目」が日によって変わらないように、日時を固定する
    around do |example|
      # 11/13日で11月2週目で固定となる
      travel_to(Time.zone.local(2026, 11, 13, 10, 0)) { example.run }
    end

    it "宛先がメンバーのメールアドレスになっている" do
      expect(mail.to).to eq [ user.email ]
    end

    it "件名に月・週・グループ名が入っている" do
      expect(mail.subject).to eq "11月2週目 家族の近況報告のタイミングがきました！"
    end

    it "本文にグループTLへのリンクが入っている" do
      # HTML版とtext版を両方チェック
      expect(mail.html_part.body.decoded).to include group_url(group)
      expect(mail.text_part.body.decoded).to include group_url(group)
    end
  end
end

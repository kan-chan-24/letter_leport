require "rails_helper"

RSpec.describe TimelinePeriod, type: :model do
  describe "バリデーション" do
    it "開始日時と終了日時があれば有効" do
      expect(build(:timeline_period)).to be_valid
    end

    it "開始日時がなければ無効" do
      expect(build(:timeline_period, started_at: nil)).to be_invalid
    end

    it "終了日時がなければ無効" do
      expect(build(:timeline_period, ended_at: nil)).to be_invalid
    end
  end

  describe "#posted_by?" do
    let(:period) { create(:timeline_period) }
    let(:user) { create(:user) }

    it "その期間に投稿していれば true" do
      create(:post, user: user, group: period.group, timeline_period: period)
      expect(period.posted_by?(user)).to be true
    end

    it "その期間に投稿していなければ false" do
      expect(period.posted_by?(user)).to be false
    end

    it "別の期間に投稿していても、この期間は false" do
      other_period = create(:timeline_period, group: period.group)
      create(:post, user: user, group: period.group, timeline_period: other_period)
      expect(period.posted_by?(user)).to be false
    end
  end

  describe "#active?" do
    it "終了日時が未来なら true" do
      period = build(:timeline_period, started_at: 1.day.ago, ended_at: 1.day.from_now)
      expect(period.active?).to be true
    end

    it "終了日時が過去なら false" do
      period = build(:timeline_period, started_at: 2.days.ago, ended_at: 1.day.ago)
      expect(period.active?).to be false
    end
  end

  describe "#heading_label" do
    let(:group) { create(:group) }

    def period_starting(time)
      build(:timeline_period, group: group, started_at: time, ended_at: time + 7.days)
    end

    context "週1のとき" do
      before { group.update!(frequency: "one_week") }

      it "月をまたぐ週は開始日の月で数える" do
        expect(period_starting(Time.zone.local(2026, 10, 27)).heading_label).to eq "10月4週目"
      end

      it "29日以降に始まる週は5週目になる" do
        expect(period_starting(Time.zone.local(2026, 11, 29)).heading_label).to eq "11月5週目"
      end
    end

    context "月1のとき" do
      before { group.update!(frequency: "one_month") }

      it { expect(period_starting(Time.zone.local(2026, 11, 1)).heading_label).to eq "11月" }
    end

    context "3ヶ月に1回のとき" do
      before { group.update!(frequency: "three_month") }

      it "年をまたいでも月の範囲で表示する" do
        expect(period_starting(Time.zone.local(2026, 11, 1)).heading_label).to eq "11月〜1月"
      end
    end
  end
end

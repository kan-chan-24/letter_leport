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
end

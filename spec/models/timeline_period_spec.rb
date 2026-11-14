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
end

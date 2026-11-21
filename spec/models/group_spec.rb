require "rails_helper"

RSpec.describe Group, type: :model do
  describe "バリデーション" do
    it "グループ名と通知頻度があれば有効" do
      expect(build(:group)).to be_valid
    end

    it "グループ名が空だと無効" do
      group = build(:group, name: "")

      expect(group).not_to be_valid
      expect(group.errors[:name]).to be_present
    end
  end

  describe "招待トークン" do
    it "グループを作ると、招待トークンが自動で入る" do
      expect(build(:group).invite_token).to be_present
    end

    it "グループごとに違う招待トークンになる" do
      expect(create(:group).invite_token).not_to eq create(:group).invite_token
    end
  end

  describe "作成時の期間" do
    it "グループを作成すると、期間が1件作られる" do
      # 件数が増えたかでチェック
      expect { create(:group) }.to change(TimelinePeriod, :count).by(1)
    end

    it "最初の期間は、開始が作成日時・終了が次回通知日時になる" do
      group = create(:group).reload
      period = group.current_period

      expect(period.started_at).to eq group.created_at
      expect(period.ended_at).to eq group.next_notify_at
    end
  end

  describe "#current_period" do
    it "最も新しい期間を返す" do
      group = create(:group)
      newer = group.timeline_periods.create!(started_at: 1.day.from_now, ended_at: 1.month.from_now)

      expect(group.current_period).to eq newer
    end
  end

  describe "通知頻度を変更したときの期間" do
    let!(:group) { create(:group) } # 頻度は one_month

    it "今の期間の終了日時が、新しい次回通知日時に更新される" do
      group.update!(frequency: "one_week")

      expect(group.current_period.ended_at).to eq group.reload.next_notify_at
    end

    it "名前だけの変更では、今の期間の終了日時は変わらない" do
      expect { group.update!(name: "新しい名前") }
        .not_to change { group.current_period.ended_at }
    end
  end
end

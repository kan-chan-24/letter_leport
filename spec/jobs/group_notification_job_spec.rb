# spec/jobs/group_notification_job_spec.rb
require "rails_helper"

RSpec.describe GroupNotificationJob, type: :job do
  # テスト中の「現在時刻」を固定する
  before { travel_to Time.zone.local(2026, 11, 9, 10, 0) }

  let!(:past_group) do
    create(:group).tap do |group|
      group.update_columns(
        interval_unit: "week",
        interval_count: 1,
        next_notify_at: Time.zone.local(2026, 11, 9, 9, 0)
      )
    end
  end

  let!(:future_group) do
    create(:group, next_notify_at: Time.zone.local(2026, 11, 9, 11, 0))
  end

  it "通知日時を過ぎたグループは、前回の通知日時の1週間後に更新される" do
    puts "===== ジョブ実行前 ====="
    pp past_group.reload.attributes   # ← 一時的に追加
    described_class.perform_now
    expect(past_group.reload.next_notify_at).to eq Time.zone.local(2026, 11, 16, 9, 0)
  end

  it "まだ通知日時が来ていないグループは変更されない" do
    expect { described_class.perform_now }
      .not_to change { future_group.reload.next_notify_at }
  end

  it "続けて2回実行しても、2回目は更新されない" do
    described_class.perform_now
    first_result = past_group.reload.next_notify_at

    described_class.perform_now
    expect(past_group.reload.next_notify_at).to eq first_result
  end
end

# spec/jobs/group_notification_job_spec.rb
require "rails_helper"

RSpec.describe GroupNotificationJob, type: :job do
  # テスト中の「現在時刻」を固定する（2026/11/9/10:00）
  before { travel_to Time.zone.local(2026, 11, 9, 10, 0) }

  # 通知日時が過ぎたグループを用意する
  let!(:past_group) do
    create(:group, frequency: "one_week").tap do |group|
      group.update_column(:next_notify_at, Time.zone.local(2026, 11, 9, 9, 0))
    end
  end

  # 通知日時がまだ来ていないグループを用意する
  let!(:future_group) do
    create(:group).tap do |group|
      group.update_columns(next_notify_at: Time.zone.local(2026, 11, 9, 11, 0))
    end
  end

  it "通知日時を過ぎたグループは、前回の通知日時の1週間後に更新される" do
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

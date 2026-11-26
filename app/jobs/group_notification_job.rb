class GroupNotificationJob < ApplicationJob
  queue_as :default

  def perform
    # 通知日時を過ぎたグループだけ取得
    Group.includes(:users).where(next_notify_at: ..Time.current).find_each do |group|
      # 今回の通知日時（＝新しい期間の開始日時）を、上書きする前に取っておく
      notified_at = group.next_notify_at

      # 次回の通知日時を決めるサービスクラスを呼び出し
      next_notify_at = NotifyAtCalculator.following_notify_at(
        previous_notify_at: group.next_notify_at,
        interval_unit: group.interval_unit,
        interval_count: group.interval_count
      )

      # 次回通知日時の更新と新しい期間の作成を、まとめて保存する（片方だけ成功したら困るため）
      ActiveRecord::Base.transaction do
        # 次回通知日時の更新
        group.update!(next_notify_at: next_notify_at)
        # 新しい期間の作成
        group.timeline_periods.create!(started_at: notified_at, ended_at: next_notify_at)
      end

      # 保存が成功してから、メンバー全員へ近況報告を促すメールを送る
      group.users.each do |user|
        NotificationMailer.with(user: user, group: group).report_reminder.deliver_later
      end
    end
  end
end

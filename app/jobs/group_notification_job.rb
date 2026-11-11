class GroupNotificationJob < ApplicationJob
  queue_as :default

  def perform
    # 通知日時を過ぎたグループだけ取得
    Group.where(next_notify_at: ..Time.current).find_each do |group|
      # 次回の通知日時を決めるサービスクラスを呼び出し
      next_notify_at = NotifyAtCalculator.following_notify_at(
        previous_notify_at: group.next_notify_at,
        interval_unit: group.interval_unit,
        interval_count: group.interval_count
      )
      # 次回通知日を上書き
      group.update!(next_notify_at: next_notify_at)

      # 最後に投稿促し通知を行う
      Rails.logger.info("[通知] group_id=#{group.id} name=#{group.name}")
    end
  end
end

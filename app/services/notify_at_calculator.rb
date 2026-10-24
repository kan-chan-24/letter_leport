class NotifyAtCalculator
  # グループ作成時に最初の通知日時を決めるロジック
  def self.first_notify_at(base_time:, interval_unit:, notify_day_of_week:, notify_day_of_month:, notify_hour:)
    if interval_unit == "week"

      candidate = (base_time+(notify_day_of_week-base_time.wday).days).change(hour: notify_hour)

      step = 1.week
    elsif interval_unit == "month"

      candidate = base_time.change(day: notify_day_of_month, hour: notify_hour)

      step = 1.month
    end

    if base_time >= candidate
      candidate + step
    else
      candidate
    end
  end

  # 2回目以降の次回の通知日時を決めるロジック
  def self.following_notify_at(previous_notify_at:, interval_unit:, interval_count:)
    if interval_unit == "week"
      previous_notify_at + interval_count.weeks
    elsif interval_unit == "month"
      previous_notify_at + interval_count.months
    end
  end
end

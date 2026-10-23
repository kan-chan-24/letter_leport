class NotifyAtCalculator
  def self.first_notify_at(base_time:, interval_unit:, notify_day_of_week:, notify_day_of_month:, notify_hour:)
    if interval_unit == "week"
      candidate = base_time + (notify_day_of_week - base_time.wday).days
      candidate_fix = candidate.change(hour: notify_hour)
      if base_time >= candidate_fix
        candidate_fix + 1.week
      else
        candidate_fix
      end
    elsif interval_unit == "month"
      candidate = base_time.change(day: notify_day_of_month, hour: notify_hour)
      if base_time >= candidate
        candidate + 1.month
      else
        candidate
      end
    end
  end

  def self.following_notify_at(previous_notify_at:, interval_unit:, interval_count:)
    if interval_unit == "week"
      previous_notify_at + interval_count.weeks
    elsif interval_unit == "month"
      previous_notify_at + interval_count.months
    end
  end
end

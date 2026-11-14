FactoryBot.define do
  factory :timeline_period do
    group
    started_at { Time.current }
    ended_at { 1.week.from_now }
  end
end

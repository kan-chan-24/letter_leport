FactoryBot.define do
  factory :group do
    name { "MyString" }
    invite_token { "MyString" }
    interval_unit { 1 }
    interval_count { 1 }
    notify_day_of_week { 1 }
    notify_day_of_month { 1 }
    notify_hour { 1 }
    next_notify_at { "2026-10-24 14:35:37" }
  end
end

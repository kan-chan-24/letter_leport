FactoryBot.define do
  factory :post do
    association :user
    association :group
    timeline_period { association :timeline_period, group: group }
    physical_condition { 3 }
    daily_condition { 3 }
    fun_condition { 3 }
    content { "最近のできごと" }
  end
end

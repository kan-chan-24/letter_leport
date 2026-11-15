FactoryBot.define do
  factory :post do
    user { nil }
    group { nil }
    timeline_period { nil }
    physical_condition { 1 }
    daily_condition { 1 }
    fun_condition { 1 }
    content { "MyText" }
  end
end

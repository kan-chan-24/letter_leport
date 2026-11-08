FactoryBot.define do
  factory :group_member do
    group { nil }
    user { nil }
    role { 1 }
  end
end

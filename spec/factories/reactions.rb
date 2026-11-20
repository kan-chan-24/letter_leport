FactoryBot.define do
  factory :reaction do
    user { nil }
    post { nil }
    stamp { :thumbs_up }
  end
end

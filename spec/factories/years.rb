FactoryBot.define do
  factory :year do
    graduate_year { "高#{Faker::Number.number(digits: 3)}" }
    anno_domini { Faker::Number.number(digits: 4) }
    japanese_calendar { "平成#{Faker::Number.number(digits: 3)}" }
  end
end

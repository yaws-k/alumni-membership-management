FactoryBot.define do
  factory :year do
    graduate_year { "高#{Faker::Number.between(from: 50, to: 70)}回" }
    anno_domini { Faker::Number.between(from: 1950, to: 2020) }
    japanese_calendar { "平成#{Faker::Number.between(from: 2, to: 31)}" }
  end
end

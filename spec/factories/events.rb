FactoryBot.define do
  factory :event do
    event_name { Faker::String.random(length: 10) }
    event_date { Faker::Date.between(from: Date.today.tomorrow, to: Date.today.next_year) }
    fee { Faker::Number.number(digits: 4) }

    trait :full_fields do
      payment_only { true }
      note { Faker::String.random(length: 40) }
    end
  end
end

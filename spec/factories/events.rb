FactoryBot.define do
  factory :event do
    event_name { Faker::Alphanumeric.alphanumeric(number: 10) }
    event_date { Faker::Date.between(from: Date.today.tomorrow, to: Date.today.next_year) }
    fee { Faker::Number.number(digits: 4) }

    trait :full_fields do
      payment_only { false }
      note { Faker::String.random(length: 40) }
    end

    trait :payment do
      payment_only { true }
    end
  end
end

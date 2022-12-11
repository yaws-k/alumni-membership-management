FactoryBot.define do
  factory :event do
    event_name { Faker::Alphanumeric.alphanumeric(number: 10) }
    event_date { Faker::Date.between(from: Date.today.tomorrow, to: Date.today.next_year) }
    fee { Faker::Number.number(digits: 4) }

    trait :full_fields do
      payment_only { false }
      note { Faker::Alphanumeric.alphanumeric(number: 40) }
      annual_fee { false }
    end

    trait :payment do
      payment_only { true }
    end

    trait :annual_fee do
      payment_only { true }
      annual_fee { true }
    end
  end
end

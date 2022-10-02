FactoryBot.define do
  factory :address do
    member

    postal_code { "#{Faker::Number.number(digits:3)}-#{Faker::Number.number(digits:4)}" }
    address1 { Faker::String.random(length: 20) }

    trait :full_fields do
      address2 { Faker::String.random(length: 20) }
      unreachable { true }
    end
  end
end

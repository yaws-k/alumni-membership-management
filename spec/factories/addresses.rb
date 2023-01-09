FactoryBot.define do
  factory :address do
    member

    postal_code { "#{Faker::Number.number(digits:3)}-#{Faker::Number.number(digits:4)}" }
    address1 { Faker::Address.street_address }

    trait :full_fields do
      address2 { Faker::Address.secondary_address }
      unreachable { true }
    end
  end
end

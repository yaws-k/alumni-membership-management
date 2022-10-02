FactoryBot.define do
  factory :attendance do
    member
    event

    trait :full_fields do
      application { true }
      presence { false }
      payment_date { Date.today - 3 }
      amount { 3000 }
      note { Faker::String.random(length: 20) }
    end
  end
end

FactoryBot.define do
  factory :user do
    member

    email { Faker::Internet.email }
    password { Faker::Alphanumeric.alphanumeric(number: 10) }
    password_confirmation { password }
    unreachable { false }

    trait :full_fields do
      current_sign_in_at { Time.now - 120 }
      last_sign_in_at { Time.now - 86_400 }
      current_sign_in_ip { Faker::Internet.ip_v4_address }
      last_sign_in_ip { Faker::Internet.ip_v4_address }
      failed_attempts { Faker::Number.number(digits: 2) }
    end
  end
end

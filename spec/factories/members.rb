FactoryBot.define do
  factory :member do
    year

    family_name_phonetic { Faker::String.random }
    first_name_phonetic { Faker::String.random }
    family_name { Faker::String.random }
    first_name { Faker::String.random }
    communication { '通常' }

    trait :full_fields do
      maiden_name_phonetic { Faker::String.random }
      maiden_name { Faker::String.random }
      quit_reason { Faker::String.random }
      occupation { Faker::String.random }
      note { Faker::String.random }
      roles { %w[normal board] }
    end
  end
end

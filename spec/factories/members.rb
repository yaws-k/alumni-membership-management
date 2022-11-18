FactoryBot.define do
  factory :member do
    year

    family_name_phonetic { Faker::Name.last_name }
    first_name_phonetic { Faker::Name.first_name }
    family_name { Faker::Name.last_name }
    first_name { Faker::Name.first_name }
    communication { '通常' }

    trait :full_fields do
      maiden_name_phonetic { Faker::Name.last_name }
      maiden_name { Faker::Name.last_name }
      quit_reason { Faker::String.random }
      occupation { Faker::String.random }
      note { Faker::String.random }
      roles { %w[board] }
    end
  end
end

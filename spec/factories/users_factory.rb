# frozen_string_literal: true

FactoryBot.define do
  sequence :username do |n|
    "test_user_#{n}"
  end

  factory :user do
    username { generate :username }
    email { "#{username}@example.org" }
    password { 'supersecure' }
    admin { false }

    factory :admin do
      admin { true }
    end
  end
end

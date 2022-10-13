FactoryBot.define do
  factory :user do
    email { "user@example.org" }
    username { "a_user" }
    password { "supersecure" }
  end
end

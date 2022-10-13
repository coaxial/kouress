# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'user@example.org' }
    username { 'a_user' }
    password { 'supersecure' }
    is_admin { false }
  end
end

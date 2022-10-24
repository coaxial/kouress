# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    original_filename { 'MyString' }
    size { 1 }
    mimetype { 'MyString' }
  end
end

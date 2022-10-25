# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    original_filename { 'Test filename' }
    size_bytes { 13_371_337 }
    mimetype { 'application/pdf' }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :language do
    iso_code { ISO_639.find('en').alpha3 }
  end
end

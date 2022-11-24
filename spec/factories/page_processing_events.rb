# frozen_string_literal: true

FactoryBot.define do
  factory :page_processing_event do
    page
    state { nil }

    trait :image_generated do
      state { 'image_generated' }
    end

    factory :page_processing_event_with_image_generated, traits: [:image_generated]
  end
end

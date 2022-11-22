# frozen_string_literal: true

FactoryBot.define do
  factory :page do
    document
    sequence(:page_num) { |n| n }

    trait :text_extracted do
      text { 'Some mock text' }

      after :create do |record, _evaluator|
        record.image_generated
        record.text_extracted
      end
    end

    factory :page_with_text_extracted, traits: [:text_extracted]
  end
end

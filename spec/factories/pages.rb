# frozen_string_literal: true

FactoryBot.define do
  factory :page do
    document
    sequence(:page_num) { |n| n }
  end
end

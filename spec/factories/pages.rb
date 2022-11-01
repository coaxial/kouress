# frozen_string_literal: true

FactoryBot.define do
  factory :page do
    document
    sequence(:page_no) { |n| n }
  end
end

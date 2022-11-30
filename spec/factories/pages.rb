# frozen_string_literal: true

# == Schema Information
#
# Table name: pages
#
#  id          :bigint           not null, primary key
#  page_num    :integer          not null
#  text        :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  document_id :bigint           not null
#
# Indexes
#
#  index_pages_on_document_id  (document_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id) ON DELETE => cascade
#
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

    trait :image_generated do
      after :create do |record, _evaluator|
        record.image_generated
      end
    end

    factory :page_with_text_extracted, traits: [:text_extracted]
    factory :page_with_image_generated_state, traits: [:image_generated]
  end
end

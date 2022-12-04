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

    trait :image_generated do
      after :build do |record, _evaluator|
        filename = "#{File.basename(record.document.original_filename, '.pdf')}-#{record.page_num}.png"

        record.image.attach(
          io: file_fixture(filename).open,
          filename:,
        )
      end

      after :create do |record, _evaluator|
        record.image_generated
      end
    end

    trait :text_extracted do
      image_generated
      after :create do |record, _evaluator|
        record.update(text: "This is the mock text for page #{record.page_num}")
        record.text_extracted
      end
    end

    trait :processed do
      after :create do |record, _evaluator|
        record.process
      end
    end

    factory :page_with_text_extracted, traits: %i[image_generated text_extracted]
    factory :page_with_image_generated_state, traits: [:image_generated]
    factory :page_with_processed_state, traits: %i[image_generated text_extracted processed]
  end
end

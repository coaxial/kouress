# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    transient { document_file { file_fixture('p761-thompson.pdf') } }
    mimetype { 'application/pdf' }
    language

    after :build do |record, evaluator|
      record.file.attach(
        io: evaluator.document_file.open,
        filename: evaluator.document_file.basename.to_s,
      )
      record.size_bytes = evaluator.document_file.size
      record.original_filename = evaluator.document_file.basename.to_s
    end

    after :create do |record, _evaluator|
      DocumentsAnalysisJob.perform_now(record.id)
    end

    trait :no_embedded_text do
      transient { document_file { file_fixture('p761-thompson-notext.pdf') } }
    end

    trait :multisearchable do
      after :create do |record, _evaluator|
        record.pages.each do |page|
          GeneratePageImageJob.perform_now(page.id)
          TextExtractionJob.perform_now(page.id)
          UpdateStateForPageJob.perform_now(page.id)
          PgSearch::Multisearch.rebuild(Document)
          PgSearch::Multisearch.rebuild(Page)
        end
      end
    end

    trait :single_page do
      transient { document_file { file_fixture('8000ad.pdf') } }
    end

    trait :with_accentuated_words do
      transient { document_file { file_fixture('accented.pdf') } }
    end

    factory :document_without_embedded_text, traits: [:no_embedded_text]
    factory :single_page_document, traits: [:single_page]
    factory :multisearchable_document, traits: [:multisearchable]
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    transient { document_file { file_fixture('p761-thompson.pdf') } }
    mimetype { 'application/pdf' }

    after :build do |record, evaluator|
      record.file.attach(
        io: evaluator.document_file.open,
        filename: evaluator.document_file.basename.to_s
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

    factory :document_without_embedded_text, traits: [:no_embedded_text]
  end
end

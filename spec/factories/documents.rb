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
  end
end

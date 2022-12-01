# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id                    :bigint           not null, primary key
#  mimetype              :string           not null
#  original_filename     :string           not null
#  processed_pages_count :integer          default(0), not null
#  size_bytes            :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  language_id           :bigint           not null
#
# Indexes
#
#  index_documents_on_language_id        (language_id)
#  index_documents_on_original_filename  (original_filename)
#
FactoryBot.define do
  factory :document do
    transient { document_file { file_fixture('p761-thompson.pdf') } }
    transient { pages_count { PDF::Reader.new(document_file).page_count } }
    mimetype { 'application/pdf' }

    after :build do |record, evaluator|
      record.language = Language.first || create(:language)
      record.file.attach(
        io: evaluator.document_file.open,
        filename: evaluator.document_file.basename.to_s,
      )
      record.size_bytes = evaluator.document_file.size
      record.original_filename = evaluator.document_file.basename.to_s
    end

    trait :paginated do
      after :create do |record, evaluator|
        create_list(:page, evaluator.pages_count, document: record)
        record.paginate
      end
    end

    trait :no_embedded_text do
      transient { document_file { file_fixture('p761-thompson-notext.pdf') } }
    end

    trait :page_images_generated do
      paginated

      after :create do |record, _evaluator|
        # create_list(:page, record.pages.count, :image_generated)
        record.pages.each do |_page|
          page = Page.update(attributes_for(:page, :image_generated))
        end
      end
    end

    trait :pages_text_extracted do
      page_images_generated

      after :create do |record, _evaluator|
        record.pages.each do |page|
          page.text = "This is the mock text content for page #{page.page_num}"
          page.text_extracted
        end
      end
    end

    trait :all_pages_processed do
      pages_text_extracted

      after :create do |record, _evaluator|
        record.pages.map(&:process)
        record.processed_pages_count = record.pages.count
      end
    end

    # Expensive to run; it has to run the real jobs because Document and
    # Pages must be in the actual database for PgSearch.multisearch to see
    # them.
    trait :multisearchable do
      after :create do |record, _evaluator|
        DocumentsAnalysisJob.perform_now(record.id)
        record.pages.each do |page|
          GeneratePageImageJob.perform_now(page.id)
          TextExtractionJob.perform_now(page.id)
          UpdateStateForPageJob.perform_now(page.id)
        end

        PgSearch::Multisearch.rebuild(Document)
        PgSearch::Multisearch.rebuild(Page)
      end
    end

    trait :accented do
      transient { document_file { file_fixture('accented.pdf') } }
    end

    trait :single_page do
      transient { document_file { file_fixture('8000ad.pdf') } }
    end

    trait :with_accented_words do
      all_pages_processed

      after :create do |record, _evaluator|
        record.pages.first.text = 'Combien pèse un hipster? Un instagram.'
      end
    end

    factory :document_without_embedded_text, traits: %i[no_embedded_text multisearchable]
    factory :single_page_document, traits: %i[single_page multisearchable]
  end
end

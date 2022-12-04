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
        create_list(:page, evaluator.pages_count, document: record) do |page, i|
          # Page.page_num is a sequence and will keep increasing between
          # documents. Instead, it should match the actual page number within
          # the document.
          page.update(page_num: i + 1)
        end
        record.paginate
      end
    end

    trait :no_embedded_text do
      transient { document_file { file_fixture('p761-thompson-notext.pdf') } }
    end

    trait :page_images_generated do
      paginated

      after :create do |record, _evaluator|
        record.reload # Avoids duplicate, ghost pages!
        record.pages.each { |page| transition_page_to_state(state: :image_generated, page:) }
      end
    end

    trait :pages_text_extracted do
      page_images_generated

      after :create do |record, _evaluator|
        record.reload # Avoids duplicate, ghost pages!
        record.pages.each do |page|
          transition_page_to_state(state: :text_extracted, page:)
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
    factory :single_page_document, traits: %i[single_page paginated]
  end
end

private

def update_page_in_events(old_page_id:, new_page_id:)
  PageProcessingEvent.where(page_id: old_page_id).update(page_id: new_page_id)
end

def transition_page_to_state(page:, state: page_state)
  # Alright, this sucks: to use the :image_generated trait from the
  # :page factory, we have to delete the current page and replace it
  # with a new one. This is because there is no way to update the
  # existing page from a FactoryBot.{create,update}.
  # FactoryBot.attributes_for doesn't work either, because it skips
  # the necessary callbacks to run side effects (update
  # PageProcessingEvent, attach image, etc.)
  #
  # Once the new page is created, we have to update its ID in the
  # PageProcessingEvent entries, otherwise current_state will be
  # "unprocessed"
  old_page = page
  new_page = create(:page, state, page_num: old_page.page_num, document: old_page.document)
  update_page_in_events(old_page_id: old_page.id, new_page_id: new_page.id)
  old_page.destroy
end

# frozen_string_literal: true

# Updates the Page's state to processed.
class UpdateStateForPageJob < ApplicationJob
  queue_as :default
  retry_on ApplicationError::PageNotReady, wait: :exponentially_longer
  discard_on ActiveRecord::RecordNotFound, ApplicationError::PageAlreadyProcessed
  attr_accessor :page, :document

  def perform(page_id)
    @page = Page.find(page_id)
    @document = page.document

    # Discard job if page already processed
    raise ApplicationError::PageAlreadyProcessed.new(context: { page: }) if page.processed?

    # Retry later if previous steps not done yet
    raise ApplicationError::PageNotReady.new(context: { page: }) unless page.text_extracted?

    page.process
    update_document_state
  end

  private

  def update_document_state
    # #update_counters is required to avoid a race condition. Validations are
    # skipped, but it's fine as this is only a counter we're incrementing.
    Document.where(id: document.id).update_counters(processed_pages_count: 1, touch: true) # rubocop:disable Rails/SkipsModelValidations
    # #update_counters doesn't trigger any ActiveRecord::Callbacks so check
    # here if all pages in the document have been processed and update
    # document's state accordingly.
    document.reload
    document.process if document.processed_pages_count == document.pages.count
  end
end

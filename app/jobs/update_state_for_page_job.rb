# frozen_string_literal: true

# Updates the Page's state to processed.
class UpdateStateForPageJob < ApplicationJob
  queue_as :default
  retry_on ApplicationError::PageNotReady, wait: :exponentially_longer
  discard_on ActiveRecord::RecordNotFound
  attr_accessor :page, :document

  def perform(page_id)
    @page = Page.find(page_id)
    @document = page.document
    raise ApplicationError::PageNotReady.new(context: { page: }) unless page.text_extracted?

    document.increment(:processed_pages_count)
    page.process
    document.process if document.processed_pages_count == document.pages.count
  end
end

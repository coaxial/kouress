# frozen_string_literal: true

class UpdateStateForPageJob < ApplicationJob
  queue_as :default
  retry_on ApplicationError::PageNotReady, wait: :exponentially_longer
  discard_on ActiveRecord::RecordNotFound
  attr_accessor :page, :document

  def perform(page_id)
    @page = Page.find(page_id)
    @document = page.document
    if page.text_extracted?
      document.increment!(:processed_pages_count)
      page.process
      document.process if document.processed_pages_count == document.pages.count
    else
      raise ApplicationError::PageNotReady.new(context: { page: })
    end
  end
end

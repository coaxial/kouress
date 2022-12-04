# frozen_string_literal: true

# Extracts information from Documents and prepares Documents for further
# processing.
class DocumentsAnalysisJob < ApplicationJob
  queue_as :default
  attr_reader :document

  discard_on ActiveRecord::RecordNotFound

  def perform(document_id)
    @document = Document.find(document_id)
    extract_pages if document.unprocessed? || document.failed?
  end

  private

  def extract_pages
    create_pages
    document.paginate
  end

  def document_path
    ActiveStorage::Blob.service.path_for(document.file.key)
  end

  def handle_job_failure(additional_context = {})
    context = base_context.merge(additional_context)

    document.fail
    raise ApplicationError::SaveFailure.new(context:)
  end

  def create_pages
    reader = PDF::Reader.new(document_path)

    reader.pages.each do |pdf_page|
      page = Page.new(document:, page_num: pdf_page.number, text: nil)
      handle_job_failure unless page.save
    end
  end

  def base_context
    { document: }
  end
end

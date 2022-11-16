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

  def handle_job_failure(step, context = nil)
    document.fail
    msg = "error running #{step}"
    msg << ": #{context.inspect}" if context

    raise msg
  end

  def create_pages
    reader = PDF::Reader.new(document_path)

    reader.pages.each do |pdf_page|
      page = Page.new(document:, page_num: pdf_page.number, text: nil)
      handle_job_failure('analysis', { document:, page: }) unless page.save
    end
  end
end

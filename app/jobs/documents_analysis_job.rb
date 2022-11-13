# frozen_string_literal: true

# Extracts information from Documents and prepares Documents for further
# processing.
class DocumentsAnalysisJob < ApplicationJob
  queue_as :default
  attr_reader :document_path

  discard_on ActiveRecord::RecordNotFound

  def perform(document_id)
    @document_id = document_id
    paginate_document if document.unprocessed? || document.failed?
  end

  private

  def document
    Document.find(@document_id)
  end

  def paginate_document
    create_pages
    document.paginate
  end

  def create_pages
    @document_path = ActiveStorage::Blob.service.path_for(document.file.key)
    reader = PDF::Reader.new(document_path)

    reader.pages.each do |pdf_page|
      page = Page.new(document:, page_num: pdf_page.number, text: nil)
      page.save
    end
  end
end

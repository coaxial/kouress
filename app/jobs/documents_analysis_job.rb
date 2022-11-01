# frozen_string_literal: true

# Extracts information from Documents and prepares Documents for further
# processing.
class DocumentsAnalysisJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    @document_id = document_id
    paginate_document if document.unprocessed? || document.failed?
  end

  private

  def document
    Document.find(@document_id)
  end

  def create_pages
    path = ActiveStorage::Blob.service.path_for(document.file.key)
    reader = PDF::Reader.new(path)

    reader.pages.each do |page|
      # TODO: handle images that need OCR to get the text
      Page.create(document:, page_no: page.number, text: nil)
    end
  end

  def paginate_document
    create_pages
    document.paginate
  end
end

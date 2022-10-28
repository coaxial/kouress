# frozen_string_literal: true

# Extracts information from Documents and prepares Documents for further processing
class DocumentsAnalysisJob < ApplicationJob
  queue_as :default

  def perform(document, path_for = ActiveStorage::Blob.service.method(:path_for))
    if document.unprocessed?
      create_pages(document, path_for)
      document.paginate
    end
  rescue StandardError
    document.fail
    raise
  end

  private

  def create_pages(document, path_for)
    path = path_for.call(document.file.key)
    reader = PDF::Reader.new(path)

    reader.pages.each do |page|
      # TODO: handle images that need OCR to get the text
      Page.create(document:, page_no: page.number, text: page.text)
    end
  end
end

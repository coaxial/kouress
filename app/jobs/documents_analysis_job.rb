# frozen_string_literal: true

# Extracts information from Documents and prepares Documents for further processing
class DocumentsAnalysisJob < ApplicationJob
  queue_as :default

  def perform(document)
    path = ActiveStorage::Blob.service.path_for(document.file.key)
    reader = PDF::Reader.new(path)

    reader.pages.each do |page|
      Page.create(document:, page_no: page.number, text: page.text)
    end
  end
end

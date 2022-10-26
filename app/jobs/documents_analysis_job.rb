# frozen_string_literal: true

# Extracts information from Documents and prepares Documents for further processing
class DocumentsAnalysisJob < ApplicationJob
  queue_as :default

  def perform(path:, document_id:)
    reader = PDF::Reader.new(path)

    reader.pages.each do |page|
      Page.create(document_id:, page_no: page.number, text: page.text)
    end
  end
end

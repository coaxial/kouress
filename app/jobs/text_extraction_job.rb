# frozen_string_literal: true

class TextExtractionJob < ApplicationJob
  queue_as :default
  attr_reader :page_id, :text

  def perform(page_id)
    @page_id = page_id
    extract_text
    page.update(text:)
  end

  private

  def page
    Page.find(page_id)
  end

  def document
    Document.find(page.document.id)
  end

  def path_for(attachment)
    ActiveStorage::Blob.service.path_for(attachment.key)
  end

  def document_file_path
    path_for(document.file)
  end

  def page_image_path
    path_for(page.image)
  end

  def extract_text
    return @text if defined?(@text)

    # First try and see if there is any embedded text
    reader = PDF::Reader.new(document_file_path)
    embedded_text = reader.page(page.page_num).text
    @text = embedded_text
    return embedded_text if embedded_text.present?

    # If there isn't, use tesseract
    # TODO: Use all installed languages or the doc's language
    @text = `#{tesseract_path} #{page_image_path} stdout`
    @text
  end

  def tesseract_path
    ActiveStorage.paths[:tesseract] || 'tesseract'
  end

  def convert_page_to_image; end
end

# frozen_string_literal: true

# This job extracts the text within the page. If the PDF file has embedded
# text, then it will use that. If it doesn't, then it will OCR the page's
# image.
class TextExtractionJob < ApplicationJob
  queue_as :default
  retry_on ActiveStorage::FileNotFoundError, wait: :exponentially_longer
  discard_on ActiveRecord::RecordNotFound
  attr_reader :page_id, :page_instance

  def perform(page_id, page_instance = nil)
    # TODO: Proper error handling
    @page_id = page_id
    @page_instance = page_instance unless page_instance.nil?
    # In case this job is run before the GeneratePageImageJob, then do
    # nothing and retry later once the page image has been generated.
    handle_missing_attachment unless page.image.attached?
    add_text_to_page
  end

  private

  def page
    page_instance || Page.find(page_id)
  end

  def document
    page.document
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

  def handle_missing_attachment
    page.fail
    raise ActiveStorage::FileNotFoundError
  end

  def extracted_text
    # This is an expensive operation if OCR is required so cache the OCRed
    # text.
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

  def add_text_to_page
    if page.update(text: extracted_text)
      page.text_extracted
    else
      page.fail
      raise 'Failed to extract text'
    end
  end
end

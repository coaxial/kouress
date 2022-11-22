# frozen_string_literal: true

# This job extracts the text within the page. If the PDF file has embedded
# text, then it will use that. If it doesn't, then it will OCR the page's
# image.
class TextExtractionJob < ApplicationJob
  queue_as :default
  retry_on ActiveStorage::FileNotFoundError, wait: :exponentially_longer
  discard_on ActiveRecord::RecordNotFound
  attr_reader :page, :document, :tesseract_cmd

  # @param page_id [Integer, String] the ID for the page to process
  # @param tesseract_cmd [String] the command to use as tesseract
  def perform(page_id, tesseract_cmd = nil)
    @page = Page.find(page_id)
    @document = page.document
    @tesseract_cmd = tesseract_cmd

    # In case this job is run before the GeneratePageImageJob, then do
    # nothing and retry later once the page image has been generated.
    handle_missing_attachment unless page.image_generated?

    add_text_to_page
  end

  private

  # @param attachment [ActiveStorage::Attached] the ActiveStorage attachment to get the path for
  # @return [String] the path to the attachment
  def path_for(attachment)
    ActiveStorage::Blob.service.path_for(attachment.key)
  end

  def document_file_path
    path_for(document.file)
  end

  def page_image_path
    path_for(page.image)
  end

  # @raise ActiveStorage::FileNotFoundError
  def handle_missing_attachment
    page.fail
    raise ActiveStorage::FileNotFoundError
  end

  # Executes tesseract and either handles failure or returns the OCRed text
  # from the page image.
  # @return [String] stdout from running tesseract on the page's image
  def run_tesseract
    # TODO: Use all installed languages or the doc's language
    command = [tesseract_path, page_image_path, 'stdout'].join(' ')

    stdout, stderr, status = Open3.capture3(command)

    handle_command_failure(command:, stdout:, stderr:, status:) unless status.success?

    stdout
  end

  # Extracts the text from Page, either using the text embedded in the PDF
  # page, or via OCR with the page's image
  # @return [String] the extracted text
  def extracted_text
    # This is an expensive operation if OCR is required so cache the OCRed
    # text.
    return @text if defined?(@text)

    # First try and see if there is any embedded text
    reader = PDF::Reader.new(document_file_path)
    embedded_text = reader.page(page.page_num).text
    @text = embedded_text if embedded_text.present?
    return embedded_text if embedded_text.present?

    # If there isn't, use tesseract
    @text = run_tesseract
    @text
  end

  def tesseract_path
    tesseract_cmd || ActiveStorage.paths[:tesseract] || 'tesseract'
  end

  # @return [Hash] the base context to be used for ApplicationError instances
  def base_context
    {
      page:
    }
  end

  # @param additional_context [Hash] extra context regarding the error, beyond #base_context (optional)
  # @raise [ApplicationError::SystemCommandFailure]
  def handle_command_failure(additional_context = {})
    context = base_context.merge(additional_context)

    page.fail
    raise ApplicationError::SystemCommandFailure.new(context:)
  end

  # @param additional_context [Hash] extra context regarding the error, beyond #base_context (optional)
  # @raise [ApplicationError::AttachFailure]
  def handle_update_failure(additional_context = {})
    context = base_context.merge(additional_context)

    page.fail
    raise ApplicationError::UpdateFailure.new(context:)
  end

  def add_text_to_page
    if page.update(text: extracted_text)
      page.text_extracted
    else
      handle_update_failure(text:)
    end
  end
end

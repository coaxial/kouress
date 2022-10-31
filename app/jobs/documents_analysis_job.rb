# frozen_string_literal: true

# Extracts information from Documents and prepares Documents for further
# processing.
# ActiveStorage doesn't put the file into storage right away, so the job checks
# for the file and retries later if the file isn't there yet.
class DocumentsAnalysisJob < ApplicationJob
  MAX_ATTEMPTS = 5
  queue_as :default
  retry_on Errno::ENOENT, wait: :exponentially_longer, attempts: MAX_ATTEMPTS

  def perform(document_id)
    @document = Document.find(document_id)
    paginate_document if @document.unprocessed? || @document.failed?
  rescue Errno::ENOENT
    handle_file_not_found
  rescue StandardError
    @document.fail
    raise
  end

  private

  # Checks if file exists in storage, throws Errno::ENOENT otherwise.
  # This is necessary because ActiveStorage doesn't write files out right away.
  def check_for_file
    File.new(ActiveStorage::Blob.service.path_for(@document.file.key))
  end

  def create_pages
    path = ActiveStorage::Blob.service.path_for(@document.file.key)
    reader = PDF::Reader.new(path)

    reader.pages.each do |page|
      # TODO: handle images that need OCR to get the text
      Page.create(document: @document, page_no: page.number, text: page.text)
    end
  end

  def handle_file_not_found
    current_attempt = executions_for(Errno::ENOENT)
    Rails.logger.debug { "File not found in storage yet (attempt #{current_attempt}/#{MAX_ATTEMPTS})" }
    @document.fail
    raise unless current_attempt >= MAX_ATTEMPTS
  end

  def paginate_document
    check_for_file
    create_pages
    @document.paginate
  end
end

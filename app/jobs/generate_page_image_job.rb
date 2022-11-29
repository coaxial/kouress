# frozen_string_literal: true

# This job generates a PNG image for each page in the PDF document. These
# images will later be used for OCR (if required) and for previewing the
# document's pages.
class GeneratePageImageJob < ApplicationJob
  queue_as :default
  discard_on ActiveRecord::RecordNotFound
  attr_reader :page, :document, :pdftoppm_cmd

  # Generates a PNG of a Page and attaches it to Page#image
  # @param page_id [Integer, String] the ID for the page to process
  # @param pdftoppm_cmd [String] the command to use as pdftoppm
  def perform(page_id, pdftoppm_cmd = nil)
    @pdftoppm_cmd = pdftoppm_cmd
    @page = Page.find(page_id)
    @document = page.document

    if page.unprocessed? || page.failed?
      convert_page_to_image
      attach_image_to_page
      page.image_generated
    end
  ensure
    delete_image_file
  end

  private

  # @return [String] the path to document.file
  def document_file_path
    ActiveStorage::Blob.service.path_for(document.file.key)
  end

  # @return [String] the pdftoppm command
  def pdftoppm_path
    pdftoppm_cmd || ActiveStorage.paths[:pdftoppm] || 'pdftoppm'
  end

  # @return [String] the ppm_root for pdftoppm
  # @see man pdftoppm(1)
  def ppm_root
    directory = File.dirname(document_file_path)
    basename = File.basename(document_file_path, '.*')
    File.join(directory, basename)
  end

  # @return [Hash] the base context for this job to include in
  # ApplicationError instances
  def base_context
    {
      page:,
    }
  end

  # Runs the pdftoppm command and either returns true if it exited with 0 or
  # raises an error with context otherwise.
  # @return [Boolean] whether the command succeeded
  def run_pdftoppm
    command = [pdftoppm_path, '-f', page.page_num.to_s, '-l',
               page.page_num.to_s, '-cropbox', '-png', document_file_path,
               ppm_root,].join(' ')

    stdout, stderr, status = Open3.capture3(command)

    handle_command_failure(command:, stdout:, stderr:, status:) unless status.success?

    status.success?
  end

  # @return [String] the generated PNG file's path
  def png_file_path
    # pdftoppm pads page numbers with zeroes if more than 9 pages in the
    # document. See
    # https://gitlab.freedesktop.org/poppler/poppler/-/issues/1312
    padding_zeroes_count = document.pages.count.to_s.length
    @png_file_path = "#{ppm_root}-#{format("%0#{padding_zeroes_count}i", page.page_num)}.png"
    @png_file_path
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
  def handle_attach_failure(additional_context = {})
    context = base_context.merge(additional_context)

    page.fail
    raise ApplicationError::AttachFailure.new(context:)
  end

  # Generates a PNG image for the current PDF page
  # @return [String] path to generated PNG file
  def convert_page_to_image
    run_pdftoppm

    png_file_path
  end

  # Attaches the image (@png_file_path) to Page.image
  def attach_image_to_page
    params = { io: File.open(png_file_path),
               filename: File.basename(png_file_path),
               content_type: 'image/png', }

    handle_attach_failure(page:) unless page.image.attach(params)
  end

  # Deletes the generated PNG file
  def delete_image_file
    File.delete(png_file_path) if defined?(@png_file_path)
    @png_file_path = nil
  end
end

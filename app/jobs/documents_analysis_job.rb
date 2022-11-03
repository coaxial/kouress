# frozen_string_literal: true

# Extracts information from Documents and prepares Documents for further
# processing.
class DocumentsAnalysisJob < ApplicationJob
  queue_as :default
  attr_reader :document_path

  def perform(document_id)
    @document_id = document_id
    paginate_document if document.unprocessed? || document.failed?
  end

  private

  def document
    Document.find(@document_id)
  end

  def create_pages
    @document_path = ActiveStorage::Blob.service.path_for(document.file.key)
    reader = PDF::Reader.new(document_path)

    reader.pages.each do |pdf_page|
      # TODO: handle images that need OCR to get the text
      page_filename = "#{File.basename(document_path)}-page_numer.png"
      page = Page.new(document:, page_no: pdf_page.number, text: nil)
      page.image.attach(page_to_image(pdf_page.number) do |output|
        io: output, filename: page_filename, content_type: 'image/png'
      end)
      page.save
    end
  end

  def paginate_document
    create_pages
    document.paginate
  end

  def pdftoppm_path
    ActiveStorage.paths[:pdftoppm] || 'pdftoppm'
  end

  # rubocop:disable Naming/BlockForwarding
  def page_to_image(page_num, &block)
    directory = File.dirname(document_path)
    basename = File.basename(document_path, '.*')
    ppm_root = File.join(directory, basename)
    png_file = "#{ppm_root}-#{page_num}.png"

    system(pdftoppm_path, '-f', page_num.to_s, '-l', page_num.to_s, '-cropbox', '-png', document_path, ppm_root)
    # TODO: see if we can avoid writing the file at all
    # draw('cat', png_file, &block)
    File.open(png_file, &block)

    File.delete(png_file)
  end
  # rubocop:enable Naming/BlockForwarding
end

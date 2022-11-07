# frozen_string_literal: true

# Extracts information from Documents and prepares Documents for further
# processing.
class DocumentsAnalysisJob < ApplicationJob
  queue_as :default
  attr_reader :document_path

  discard_on ActiveRecord::RecordNotFound

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
      # FIXME: race condition where pages don't always get created, because
      #   pdftoppm can't find the file?
      # TODO: handle images that need OCR to get the text
      page = Page.new(document:, page_num: pdf_page.number, text: nil)
      png_file = page_to_image(pdf_page.number, reader.pages.count)
      page.image.attach(io: File.open(png_file), filename: File.basename(png_file).to_s, content_type: 'image/png')
      page.save
      File.delete(png_file)
    end
  end

  def paginate_document
    if document.file.attached?
      create_pages
      document.paginate
    end
  end

  def pdftoppm_path
    ActiveStorage.paths[:pdftoppm] || 'pdftoppm'
  end

  def page_to_image(page_num, page_total)
    directory = File.dirname(document_path)
    basename = File.basename(document_path, '.*')
    ppm_root = File.join(directory, basename)
    # pdftoppm pads page numbers with zeroes if more than 9 pages in the
    # document. See
    # https://gitlab.freedesktop.org/poppler/poppler/-/issues/1312
    png_file = "#{ppm_root}-#{"%0#{page_total.to_s.length}i" % page_num}.png"

    system(pdftoppm_path, '-f', page_num.to_s, '-l', page_num.to_s, '-cropbox', '-png', document_path, ppm_root)
    Rails.logger.debug { "****************************************** #{page_num}: #{png_file}" }

    png_file
  end
end

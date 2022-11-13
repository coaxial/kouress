# frozen_string_literal: true

# This job generates a PNG image for each page in the PDF document. These
# images will later be used for OCR (if required) and for previewing the
# document's pages.
class GeneratePageImageJob < ApplicationJob
  queue_as :default
  attr_reader :page_id

  def perform(page_id)
    @page_id = page_id
    page_to_image!
    attach_image!
    page.image_generated
  ensure
    delete_image_file
  end

  private

  def page
    Page.find(page_id)
  end

  def document
    page.document
  end

  def document_file_path
    ActiveStorage::Blob.service.path_for(document.file.key)
  end

  def pdftoppm_path
    ActiveStorage.paths[:pdftoppm] || 'pdftoppm'
  end

  def ppm_root
    directory = File.dirname(document_file_path)
    basename = File.basename(document_file_path, '.*')
    File.join(directory, basename)
  end

  def convert_page_to_ppm!
    system(pdftoppm_path, '-f',
           page.page_num.to_s, '-l',
           page.page_num.to_s, '-cropbox',
           '-png', document_file_path,
           ppm_root)
  end

  def png_file_path
    # pdftoppm pads page numbers with zeroes if more than 9 pages in the
    # document. See
    # https://gitlab.freedesktop.org/poppler/poppler/-/issues/1312
    padding_zeroes_count = document.pages.count.to_s.length
    @png_file_path = "#{ppm_root}-#{format("%0#{padding_zeroes_count}i", page.page_num)}.png"
    @png_file_path
  end

  # Generates a PNG image for the current PDF page
  def page_to_image!
    # TODO: proper error handling
    raise 'pdftoppm failed' unless convert_page_to_ppm!

    png_file_path
  end

  def attach_image!
    page.image.attach(io: File.open(png_file_path), filename: File.basename(png_file_path), content_type: 'image/png')
  end

  def delete_image_file
    File.delete(@png_file_path) if defined?(@png_file_path)
    @png_file_path = nil
  end
end

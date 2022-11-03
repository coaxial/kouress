# frozen_string_literal: true

class OcrJob < ApplicationJob
  queue_as :default
  attr_reader :page_id

  def perform(page_id)
    @page_id = page_id
    page.update(text:)
  end

  private

  def page
    Page.find(page_id)
  end

  def document
    Document.find(page.document.id)
  end

  def path
    ActiveStorage::Blob.service.path_for(document.file.key)
  end

  def text
    reader = PDF::Reader.new(path)
    embedded_text = reader.page(page.page_no).text
    return embedded_text if embedded_text.present?

    # So, there was no embedded text.
    # Convert to image
    page.preview(page_num: 2)
    debugger
    # see https://github.com/rails/rails/blob/f95c0b7e96eb36bc3efc0c5beffbb9e84ea664e4/activestorage/lib/active_storage/previewer.rb#L29-L92
    # Pass to tesseract
  end

  def convert_page_to_image; end
end

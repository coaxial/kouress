# frozen_string_literal: true

module ActiveStorage
  module Preview
    class PopplerPDFPagePreviewer < Previewer::PopplerPDFPreviewer
      # adds the page_num: option to select which page to render
      def preview(**options)
        download_blob_to_tempfile do |input|
          draw_page_from input, page_num do |output|
            yield io: output, filename: "#{blob.filename.base}.png", content_type: 'image/png', **options.except(:page_num)
          end
        end
      end

      private

      def draw_page_from(file, page_num = 1, &)
        Rails.logger.debug file.path
        draw(self.class.pdftoppm_path, "-f #{page_num}", "-l #{page_num}", '-cropbox', '-png', file.path, &)
      end
    end
  end
end

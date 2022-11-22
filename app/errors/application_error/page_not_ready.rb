# frozen_string_literal: true

module ApplicationError
  # To be used when the page isn't in the right state yet for the job to
  # continue. For instance, the job wants to extract text from the page, but
  # the page's image hasn't been generated yet and OCR can't proceed.
  class PageNotReady < BaseError
  end
end

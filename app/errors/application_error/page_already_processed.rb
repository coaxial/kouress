# frozen_string_literal: true

module ApplicationError
  # To be raised if the page is already processed and there is nothing to do.
  # Used in jobs to discard jobs.
  class PageAlreadyProcessed < BaseError
  end
end

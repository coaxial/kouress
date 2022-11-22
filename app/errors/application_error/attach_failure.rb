# frozen_string_literal: true

module ApplicationError
  # To be used when attaching an attachable to a record fails.
  class AttachFailure < BaseError
  end
end

# frozen_string_literal: true

module ApplicationError
  # Raised when a shell command failed to run (Kernel.system, Open3.capture3,
  # etc.)
  class SystemCommandFailure < BaseError
  end
end

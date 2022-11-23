# frozen_string_literal: true

module ApplicationError
  # The parent error for all ApplicationError instances.
  # Error message is defined in config/locales/errors.xx.yml
  class BaseError < StandardError
    attr_accessor :context

    # @param opts [Hash] the options to instantiate the error.
    # @option opts [Hash] extra context about the error, such as the models
    # involved, a system command output, etc.
    def initialize(opts = {})
      @context = opts[:context]
      super
    end

    # @return [String] the message for that error, as defined in
    # config/locales/errors.en.yml
    def message
      I18n.t("error.#{error_name.underscore}.message")
    end

    private

    # @return [String] the error's class name without its module (i.e. ApplicationError::SomeFailure => "SomeFailure"
    def error_name
      self.class.name.demodulize
    end
  end
end

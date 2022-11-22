# frozen_string_literal: true

module ApplicationError
  # The parent error for all ApplicationError instances.
  # Error message is defined in config/locales/errors.xx.yml
  class BaseError < StandardError
    attr_accessor :context

    def initialize(args = {})
      @context = args[:context]
      super
    end

    def message
      I18n.t("error.#{error_name.underscore}.message")
    end

    private

    def error_name
      self.class.name.demodulize
    end
  end
end

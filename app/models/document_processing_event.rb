# frozen_string_literal: true

# Registers events for the processing of Document
class DocumentProcessingEvent < ApplicationRecord
  belongs_to :document

  validates :state,
            inclusion: { in: Document::STATES,
                         message: ->(_object, data) { invalid_state_error_message(data[:value]) }, }

  def self.with_last_state(state)
    order('id desc').group('document_id').having(state:)
  end

  def invalid_state_error_message(value)
    "#{value.inspect} is not a valid state (valid states: #{Document::STATES.to_sentence})"
  end
end

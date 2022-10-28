# frozen_string_literal: true

# Registers events for the processing of Document
class DocumentProcessingEvent < ApplicationRecord
  belongs_to :document

  validates :state,
            inclusion: { in: Document::STATES,
                         message: lambda do |_object, data|
                           "#{data[:value].inspect} is not a valid state (valid states: #{Document::STATES})"
                         end }

  def self.with_last_state(state)
    order('id desc').group('document_id').having(state:)
  end
end

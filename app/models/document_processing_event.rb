# frozen_string_literal: true

# == Schema Information
#
# Table name: document_processing_events
#
#  id          :bigint           not null, primary key
#  state       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  document_id :bigint           not null
#
# Indexes
#
#  index_document_processing_events_on_document_id  (document_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id) ON DELETE => cascade
#
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

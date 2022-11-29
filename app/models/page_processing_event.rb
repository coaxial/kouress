# frozen_string_literal: true

# Registers events for the processing of Page
class PageProcessingEvent < ApplicationRecord
  belongs_to :page

  validates :state,
            inclusion: { in: Page::STATES,
                         message: ->(_object, data) { invalid_state_error_message(data[:value]) }, }

  def self.with_last_state(state)
    order('id desc').group('page_id').having(state:)
  end

  def invalid_state_error_message(value)
    "#{value.inspect} is not a valid state (valid states: #{Page::STATES.to_sentence})"
  end
end

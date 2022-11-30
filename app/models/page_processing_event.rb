# frozen_string_literal: true

# == Schema Information
#
# Table name: page_processing_events
#
#  id         :bigint           not null, primary key
#  state      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  page_id    :bigint           not null
#
# Indexes
#
#  index_page_processing_events_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id) ON DELETE => cascade
#
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

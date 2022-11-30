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
FactoryBot.define do
  factory :page_processing_event do
    page
    state { nil }

    trait :image_generated do
      state { 'image_generated' }
    end

    factory :page_processing_event_with_image_generated, traits: [:image_generated]
  end
end

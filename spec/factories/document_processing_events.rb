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
FactoryBot.define do
  factory :document_processing_event do
    document { nil }
  end
end

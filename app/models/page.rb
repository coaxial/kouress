# frozen_string_literal: true

# == Schema Information
#
# Table name: pages
#
#  id          :bigint           not null, primary key
#  page_num    :integer          not null
#  text        :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  document_id :bigint           not null
#
# Indexes
#
#  index_pages_on_document_id  (document_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id) ON DELETE => cascade
#
class Page < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:text],
                  additional_attributes: ->(page) { { document_id: page.document_id } },
                  if: :processed?,
                  update_if: :text_changed?
  belongs_to :document
  has_many :events, dependent: :delete_all, class_name: 'PageProcessingEvent'
  has_one_attached :image
  default_scope { order(:page_num) }
  after_commit :generate_page_image, on: :create
  after_commit :extract_text, on: :create
  after_commit :update_state, on: :update

  # State machine
  # mermaid-js diagram:
  # https://kroki.io/mermaid/svg/eNorLkksSXXJTEwvSszVLTPiUlCI1opV0NW1UyjNKyjKT04tLk5NAYrC2WA5oBouoCCSErBwZm5iemp8empeahHQ1BQsKtISM3PAEmhKUSUhDBxGYtNZklpREg_ERYnJEEWoAjhNJ0YfIhQADRhkRg
  #
  # stateDiagram-v2
  # [*] --> unprocessed
  # processed --> [*]

  # unprocessed --> image_generated
  # unprocessed --> failed
  # image_generated --> failed
  # failed --> image_generated
  # image_generated --> text_extracted
  # text_extracted --> failed
  # failed --> text_extracted
  # text_extracted --> processed
  #
  STATES = %w[unprocessed image_generated text_extracted processed failed].freeze
  delegate :unprocessed?, :image_generated?, :text_extracted?, :processed?,
           :failed?, to: :current_state

  def current_state
    (events.last.try(:state) || STATES.first).inquiry
  end

  def process
    events.create! state: 'processed' if text_extracted?
  end

  def image_generated
    events.create! state: 'image_generated' if unprocessed? || failed?
  end

  def text_extracted
    events.create! state: 'text_extracted' if image_generated? || failed?
  end

  def fail
    events.create! state: 'failed' if unprocessed? || image_generated? || text_extracted?
  end

  def self.unprocessed
    joins(:events).merge PageProcessingEvent.with_last_state('unprocessed')
  end
  # /State machine

  private

  def generate_page_image
    GeneratePageImageJob.perform_later(id)
  end

  def extract_text
    TextExtractionJob.perform_later(id)
  end

  def update_state
    UpdateStateForPageJob.perform_later(id)
  end
end

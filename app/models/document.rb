# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id                    :bigint           not null, primary key
#  mimetype              :string           not null
#  original_filename     :string           not null
#  processed_pages_count :integer          default(0), not null
#  size_bytes            :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  language_id           :bigint           not null
#
# Indexes
#
#  index_documents_on_language_id        (language_id)
#  index_documents_on_original_filename  (original_filename)
#
class Document < ApplicationRecord
  include ActiveModel::Validations
  include PgSearch::Model
  multisearchable against: %i[id original_filename],
                  additional_attributes: ->(document) { { document_id: document.id } },
                  if: :processed?
  has_many :pages, dependent: :delete_all
  has_many :events, dependent: :delete_all, class_name: 'DocumentProcessingEvent'
  belongs_to :language
  has_one_attached :file
  validates_with UniqueFileValidator, on: :create
  after_commit :analyze_document, on: :create

  # State machine
  # mermaid-js diagram:
  # https://kroki.io/mermaid/svg/eNorLkksSXXJTEwvSszVLTPiUlCI1opV0NW1UyjNKyjKT04tLk5NAYrC2WA5oBouoCCSErBwQWJ6Zh7QvBQscmmJmTlgCQgDQz2cjaoaVRjhIgBB4zrm
  #
  # stateDiagram-v2
  #   [*] --> unprocessed
  #   processed --> [*]

  #   unprocessed --> paginated
  #   unprocessed --> failed
  #   failed --> paginated
  #   paginated --> failed
  #   paginated --> processed

  STATES = %w[unprocessed paginated processed failed].freeze
  delegate :unprocessed?, :paginated?, :processed?, :failed?, to: :current_state

  def current_state
    (events.last.try(:state) || STATES.first).inquiry
  end

  def process
    events.create! state: 'processed' if paginated?
  end

  def paginate
    events.create! state: 'paginated' if unprocessed? || failed?
  end

  def fail
    events.create! state: 'failed' if unprocessed?
  end

  def self.unprocessed
    joins(:events).merge DocumentProcessingEvent.with_last_state('unprocessed')
  end
  # /State machine

  def self.supported_mimetypes
    %w[application/pdf]
  end

  private

  def analyze_document
    DocumentsAnalysisJob.perform_later(id)
  end
end

# frozen_string_literal: true

class Document < ApplicationRecord
  has_many :pages, dependent: :delete_all
  has_many :events, dependent: :delete_all, class_name: 'DocumentProcessingEvent'
  has_one_attached :file
  after_commit :analyze_document, unless: :processed?

  # State machine
  # Valid transitions:
  # unprocessed => paginated => processed
  #             => failed    => paginated => processed
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
    DocumentsAnalysisJob.perform_later(self)
  end
end

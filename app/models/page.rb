# frozen_string_literal: true

class Page < ApplicationRecord
  belongs_to :document
  has_one_attached :image
  default_scope { order(:page_num) }
  after_commit :extract_text, on: :create

  private

  def extract_text
    TextExtractionJob.perform_later(id)
  end
end

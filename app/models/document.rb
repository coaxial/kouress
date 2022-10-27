# frozen_string_literal: true

class Document < ApplicationRecord
  has_many :pages, dependent: :delete_all
  has_one_attached :file
  # TODO: callback is called twice and has twice the pages
  after_save :analyze_document, unless: :pages_populated?

  def self.supported_mimetypes
    %w[application/pdf]
  end

  private

  def analyze_document
    DocumentsAnalysisJob.perform_later(self)
  end

  def pages_populated?
    pages.count.positive?
  end
end

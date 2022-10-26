# frozen_string_literal: true

class Document < ApplicationRecord
  has_many :pages, dependent: :delete_all
  has_one_attached :file
  after_save :analyze_document, unless: :pages_populated?

  def self.supported_mimetypes
    %w[application/pdf]
  end

  private

  def analyze_document
    path = ActiveStorage::Blob.service.path_for(file.key)
    DocumentsAnalysisJob.perform_later(path:, document_id: id)
  end

  def pages_populated?
    pages.count.positive?
  end
end

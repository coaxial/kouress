# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentsAnalysisJob, type: :job do
  context 'with a PDF file' do
    let(:document) { create(:document) }

    it 'extracts the pages', :focus do
      path = ActiveStorage::Blob.service.path_for(document.file.key)
      ActiveJob::Base.queue_adapter = :test
      described_class.perform_now(path:, document_id: document.id)

      expect(document.pages.count).to eq(3)
    end
  end
end

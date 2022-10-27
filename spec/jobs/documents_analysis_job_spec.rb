# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentsAnalysisJob, type: :job do
  context 'with a PDF file' do
    let(:document) { create(:document) }

    it 'schedules document analysis' do
      expect(described_class).to have_been_enqueued.with(document)
    end

    it 'extracts pages' do
      described_class.perform_now(document)

      expect(document.pages.count).to eq(3)
    end
  end
end

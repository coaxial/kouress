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

    it 'extracts pages only once' do
      2.times { described_class.perform_now(document) }

      expect(document.pages.count).to eq(3)
    end
  end

  context 'when the job fails' do
    let(:document) { create(:document) }
    let(:path_for_mock) { ->(_path) { raise 'Mock error' } }

    it "doesn't swallow the exception" do
      expect { described_class.perform_now(document, path_for_mock) }.to raise_error(RuntimeError, 'Mock error')
    end

    it 'stays unprocessed' do
      described_class.perform_now(document, path_for_mock)
      # this is fine, we _want_ to suppress the exception: having the
      # expectation in ensure means it's always run even when no exceptions are
      # raised.
    rescue RuntimeError # rubocop:disable Lint/SuppressedException
    ensure
      expect(document.current_state).to be_unprocessed
    end
  end
end

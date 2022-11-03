# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentsAnalysisJob do
  include ActiveJob::TestHelper

  context 'with a PDF file' do
    let(:document) { create(:document) }

    after { clear_enqueued_jobs }

    it 'schedules document analysis' do
      expect(described_class).to have_been_enqueued.with(document.id)
    end

    it 'extracts pages' do
      described_class.perform_now(document.id)

      expect(document.pages.count).to eq(3)
    end

    it 'extracts pages only once' do
      2.times { described_class.perform_now(document.id) }

      expect(document.pages.count).to eq(3)
    end

    it 'changes state' do
      described_class.perform_now(document.id)

      expect(document.current_state).to be_paginated
    end
  end

  context 'when a document is failed' do
    let(:document) { create(:document) }

    before { document.fail }

    it 'can be tried again' do
      described_class.perform_now(document.id)

      expect(document.current_state).to be_paginated
    end
  end
end

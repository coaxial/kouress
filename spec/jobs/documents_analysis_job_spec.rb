# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentsAnalysisJob, type: :job do
  include ActiveJob::TestHelper

  context 'with a PDF file' do
    let(:document) { create(:document) }

    after { clear_enqueued_jobs }

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

    it 'changes state' do
      described_class.perform_now(document)

      expect(document.current_state).to be_paginated
    end
  end

  context 'when the job fails' do
    let(:document) { create(:document) }

    before { allow(File).to receive(:new).and_raise(RuntimeError, 'Mock error') }

    it "doesn't swallow the exception" do
      expect { described_class.perform_now(document) }.to raise_error(RuntimeError, 'Mock error')
    end

    it 'changes state to failed' do
      described_class.perform_now(document)
      # this is fine, we _want_ to suppress the exception: having the
      # expectation in `ensure` means it's always run even when no exceptions
      # are raised, and avoids having the test pass.
    rescue RuntimeError # rubocop:disable Lint/SuppressedException
    ensure
      expect(document.current_state).to be_failed
    end
  end

  context "when the file hasn't been written yet" do
    let(:document) { create(:document) }

    before { allow(File).to receive(:new).and_raise(Errno::ENOENT) }

    it 'changes state to failed' do
      described_class.perform_now(document)

      expect(document.current_state).to be_failed
    end

    it 'retries later' do
      described_class.perform_now(document)

      expect(described_class).to have_been_enqueued.exactly(:twice)
    end

    context 'when it fails too many times' do
      it 'eventually changes state to failed' do
        allow_any_instance_of(described_class).to receive(:executions_for).and_return(DocumentsAnalysisJob::MAX_ATTEMPTS)
        described_class.perform_now(document)

        expect(document.current_state).to be_failed
      end
    end
  end

  context 'when a document is failed' do
    let(:document) { create(:document) }

    before { document.fail }

    it 'can be tried again' do
      described_class.perform_now(document)

      expect(document.current_state).to be_paginated
    end
  end
end

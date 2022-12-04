# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TextExtractionJob do
  include ActiveJob::TestHelper

  after { clear_enqueued_jobs }

  context 'with a PDF file' do
    context 'when the job runs without errors' do
      let(:text) do
        <<~OCR.squish
          Reflections on Trusting Trust To what extent should one trust a statement
          that a program is free of Trojan horses? Perhaps it is more important to
          trust the people who wrote the software. KEN THOMPSON
        OCR
      end

      context 'when there is text embedded' do
        let(:document) { create(:document, :page_images_generated) }

        before do
          document.reload
          described_class.perform_now(document.pages.first.id)
        end

        it 'extracts the text' do
          expect(document.pages.first.text.squish).to include(text)
        end

        it 'changes state to text_extracted' do
          expect(document.pages.first).to be_text_extracted
        end
      end

      context 'when there is no text embedded' do
        let(:document) { create(:document, :no_embedded_text, :page_images_generated) }

        before do
          document.reload
          described_class.perform_now(document.pages.first.id)
        end

        # This is slow because it's running tesseract for real.
        it 'extracts the text' do
          expect(document.pages.first.text.squish).to include(text)
        end

        # This is slow because it's running tesseract for real.
        it 'changes state to text_extracted' do
          expect(document.pages.first).to be_text_extracted
        end
      end
    end
  end

  context 'when the job errors' do
    let(:document) { create(:document, :no_embedded_text, :page_images_generated) }
    let(:tesseract_cmd) { 'false' }

    before do
      document.reload
      described_class.perform_now(document.pages.first.id, tesseract_cmd)
    # This is intentional, the job is meant to fail because tesseract_cmd
    # is `false` which will always exit 1.
    rescue StandardError # rubocop:disable Lint/SuppressedException
    end

    it 'changes state to failed' do
      expect(document.pages.first).to be_failed
    end

    it "includes the command's context in the error" do
      expect do
        # Using the second page because the first has already been failed
        # above, and it won't try to extract the text again if
        # page.text_extracted?
        described_class.perform_now(document.pages.second.id,
                                    tesseract_cmd,)
      end.to raise_error(ApplicationError::SystemCommandFailure)
    end
  end
end

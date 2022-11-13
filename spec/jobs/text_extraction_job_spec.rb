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
        let(:document) { create(:document) }

        before do
          document.pages.each { |page| GeneratePageImageJob.perform_now(page.id) }
        end

        context 'when processing a page' do
          before do
            described_class.perform_now(document.pages.first.id)
            document.reload
          end

          it 'extracts the text' do
            expect(document.pages.first.text.squish).to include(text)
          end

          it 'changes state to text_extracted' do
            expect(document.pages.first).to be_text_extracted
          end
        end
      end

      context 'when there is no text embedded' do
        let(:document) { create(:document_without_embedded_text) }

        before do
          document.pages.each { |page| GeneratePageImageJob.perform_now(page.id) }
          raise 'Page image attachment missing' unless document.pages.first.image.attached?

          described_class.perform_now(document.pages.first.id)
          document.reload
        end

        it 'extracts the text' do
          expect(document.pages.first.text.squish).to include(text)
        end

        it 'changes state to text_extracted' do
          expect(document.pages.first).to be_text_extracted
        end
      end
    end
  end

  context 'when the job errors' do
    pending 'changes state to failed'
  end
end

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
    let(:document) { create(:document) }
    let(:mock_page) { double(document.pages.first) }

    before do
      document.pages.each { |page| GeneratePageImageJob.perform_now(page.id) }
      # allow(Page).to receive(:new).and_return(page)
      # allow(page).to receive(:update).and_return(false)
      # document.reload
    end

    it 'changes state to failed', :focus do
      # page = object_double(Page.new, update: false)
      # double('Page', update: false)
      # mock_page = double('Page')
      # allow(Page).to receive(:find).and_return(mock_page)
      allow(mock_page).to receive(:update).and_return(false)
      allow(mock_page).to receive(:image)
      allow(mock_page.image).to receive(:attached?)
      # allow(mock_page).to receive(:update).and_return(false)
      # allow(document.pages.first).to receive(:update).and_return(false)

      # described_class.perform_now(document.pages.first.id, mock_page)
      # expect(mock_page.update(text: 'bar')).to be('weeeee')
      described_class.perform_now(document.pages.first.id, mock_page)
      expect(document.pages.first).to be_failed
    end
  end
end

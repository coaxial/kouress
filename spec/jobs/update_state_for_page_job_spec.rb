# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateStateForPageJob, type: :job do
  context 'when not all pages have been processed' do
    let(:document) { create(:document, :pages_text_extracted) }
    let(:page) { document.pages.first }

    before do
      document.reload
      described_class.perform_now(page.id)
    end

    it 'sets page state to processed' do
      expect(page).to be_processed
    end

    it "doesn't set document state to processed" do
      expect(page.document).not_to be_processed
    end
  end

  context 'when all pages have been processed' do
    let(:document) { create(:document, :single_page, :pages_text_extracted) }

    before do
      document.reload
      described_class.perform_now(document.pages.first.id)
    end

    it "changes document's state to processed" do
      expect(document).to be_processed
    end
  end

  context 'when attempting to process a page in the wrong state' do
    let(:document) { create(:single_page_document) }

    before do
      document.reload
      described_class.perform_now(document.pages.first.id)
    end

    it "doesn't process the page" do
      expect(document.pages.first).not_to be_processed
    end

    it "doesn't process the document" do
      expect(document).not_to be_processed
    end
  end
end

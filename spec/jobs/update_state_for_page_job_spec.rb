# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateStateForPageJob, type: :job do
  context 'when not all pages have been processed' do
    let(:page) { create(:page_with_text_extracted) }

    before { described_class.perform_now(page.id) }

    it 'sets page state to processed' do
      expect(page).to be_processed
    end

    it "doesn't set document state to processed" do
      expect(page.document).not_to be_processed
    end
  end

  context 'when all pages have been processed' do
    let(:document) { create(:single_page_document) }

    before do
      document.pages.first.update(text: 'Some mock text')
      document.pages.first.image_generated
      document.pages.first.text_extracted

      described_class.perform_now(document.pages.first.id)
    end

    it "changes document's state to processed", :focus do
      expect(document).to be_processed
    end
  end
end

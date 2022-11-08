# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TextExtractionJob do
  include ActiveJob::TestHelper

  after { clear_enqueued_jobs }

  context 'with a PDF file' do
    let(:text) do
      'Reflections on Trusting Trust To what extent should one trust a statement that a program is free of Trojan horses? Perhaps it is more important to trust the people who wrote the software. KEN THOMPSON'
    end

    context 'when there is text embedded' do
      let!(:document) { create(:document) }

      before do
        document.pages.each do |page|
          GeneratePageImageJob.perform_now(page.id)
        end
        described_class.perform_now(document.pages.first.id)
      end

      it 'extracts the text', :focus do
        raise 'Page image attachment missing' unless document.pages.first.image.attached?

        expect(document.pages.first.text.squish).to include(text)
      end
    end

    context 'when there is no text embedded' do
      let!(:document) { create(:document_without_embedded_text) }

      before { described_class.perform_now(document.pages.first.id) }

      it 'extracts the text' do
        expect(document.pages.first.text.squish).to include(text)
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GeneratePageImageJob, type: :job do
  include ActiveJob::TestHelper

  after { clear_enqueued_jobs }

  context 'with a PDF file' do
    let!(:document) { create(:document) }

    context "when the page's job succeeds" do
      before { described_class.perform_now(document.pages.first.id) }

      it "attaches the page's image" do
        expect(document.pages.first.image).to be_attached
      end

      it 'changes state to image_generated' do
        expect(document.pages.first).to be_image_generated
      end
    end

    context "when the page's job fails" do
      pending 'changes state to failed'
    end
  end
end

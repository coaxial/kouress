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
      # Intentionally fail the pdftoppm command
      let(:pdftoppm_cmd) { 'false' }

      before do
        described_class.perform_now(document.pages.first.id, pdftoppm_cmd)
        # This is intentional, the job is meant to fail because pdftoppm_cmd
        # is `false` which will always exit 1.
      rescue StandardError # rubocop:disable Lint/SuppressedException
      end

      it 'changes state to failed' do
        expect(document.pages.first).to be_failed
      end

      it 'raises ApplicationError::SystemCommandFailure' do
        expect do
          described_class.perform_now(document.pages.first.id,
                                      pdftoppm_cmd,)
        end.to raise_error(ApplicationError::SystemCommandFailure)
      end
    end
  end
end

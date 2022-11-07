# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GeneratePageImageJob, type: :job do
  include ActiveJob::TestHelper

  after { clear_enqueued_jobs }

  context 'with a PDF file' do
    let!(:document) { create(:document) }

    before { described_class.perform_now(document.pages.first.id) }

    it "attaches the page's image" do
      expect(document.pages.first.image).to be_attached
    end
  end
end

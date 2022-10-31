# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DeleteDocuments', type: :feature do
  let(:user) { create(:user) }
  let!(:document) { create(:document) }

  before do
    login user
    visit documents_path
    click_link "delete-doc-#{document.id}"
  end

  it 'deletes a document' do
    expect(page).not_to have_selector(".document-#{document.id}")
  end

  it 'shows a confirmation' do
    expect(page).to have_text(I18n.t('documents.destroy.success'))
  end
end

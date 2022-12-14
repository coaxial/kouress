# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SingleDocumentUploads' do
  let(:user) { create(:user) }
  let!(:language) do
    lang = create(:language)
    ISO_639.find(lang.iso_code).english_name
  end

  before do
    login user
    visit new_document_path
  end

  context 'with a PDF' do
    before do
      attach_file('File', file_fixture('p761-thompson.pdf'))
      select(language, from: 'Language')
      click_button I18n.t('documents.form.upload')
    end

    it 'can upload a document' do
      document = Document.last
      visit documents_path
      expect(page).to have_selector("#document-#{document.id}")
    end

    it 'shows a success message' do
      expect(page).to have_text('successfully')
    end
  end

  context 'with unsupported mimetype' do
    before do
      attach_file('File', file_fixture('8000ad.txt'))
      select(language, from: 'Language')
      click_button I18n.t('documents.form.upload')
    end

    it 'shows a message' do
      expect(page).to have_text("isn't supported")
    end
  end
end

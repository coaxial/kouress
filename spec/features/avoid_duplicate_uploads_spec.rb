# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AvoidDuplicateUploads' do
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

    context 'when uploading a duplicate' do
      # Upload the same file again
      before do
        attach_file('File', file_fixture('p761-thompson.pdf'))
        select(language, from: 'Language')
        click_button I18n.t('documents.form.upload')
      end

      it 'rejects the upload' do
        visit documents_path

        expect(page).not_to have_selector('.document-2')
      end

      it 'shows a message' do
        expect(page).to have_text('document is already')
      end
    end
  end
end

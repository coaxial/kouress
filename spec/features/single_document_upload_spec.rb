# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SingleDocumentUploads', type: :feature do
  let(:user) { create(:user) }

  before do
    login user
    visit new_document_path
  end

  context 'with a PDF' do
    before do
      attach_file('File', file_fixture('p761-thompson.pdf'))
      click_button I18n.t('documents.form.upload')
    end

    it 'can upload a document' do
      expect(page).to have_text('p761-thompson.pdf')
    end
  end

  context 'with unsupported mimetype' do
    before do
      attach_file('File', file_fixture('8000ad.txt'))
      click_button I18n.t('documents.form.upload')
    end

    it "doesn't keep the document" do
      expect(page).to have_text(I18n.t('documents.create.unsupported_mimetype'))
    end
  end
end

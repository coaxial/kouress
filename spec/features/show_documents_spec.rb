# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ShowDocuments' do
  let(:user) { create(:user) }
  let!(:language) do
    lang = create(:language)
    ISO_639.find(lang.iso_code).english_name
  end

  before do
    login user
    visit new_document_path
    attach_file('File', file_fixture('p761-thompson.pdf'))
    select(language, from: 'Language')
    click_button I18n.t('documents.form.upload')
  end

  context 'when on the homepage' do
    before { visit root_path }

    it 'shows the uploaded documents' do
      expect(page).to have_text('p761-thompson.pdf')
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ShowDocuments', type: :feature do
  let(:user) { create :user }

  before do
    login user
    visit new_document_path
    attach_file('File', file_fixture('p761-thompson.pdf'))
    click_button I18n.t('documents.form.upload')
  end

  context 'when on the homepage' do
    before { visit root_path }

    it 'shows the uploaded documents' do
      expect(page).to have_text('p761-thompson.pdf')
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SingleDocumentUploads', type: :feature do
  let(:user) { create(:user) }

  before do
    login user
    visit new_document_path
  end

  it 'can upload a document' do
    attach_file('File', file_fixture('p761-thompson.pdf'))
    click_button I18n.t('documents.form.upload')

    expect(page).to have_text('p761-thompson.pdf')
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searches', type: :system do
  before do
    driven_by(:rack_test)

    login user
    visit home_path
  end

  let(:user) { create :user }
  let!(:language) do
    lang = create :language
    ISO_639.find(lang.iso_code).english_name
  end
  let!(:document) { create :document, :accented, :multisearchable }

  context 'when searching for one word' do
    before do
      fill_in 'query', with: 'hipster'
      click_on 'Search'
    end

    it 'shows the matching documents' do
      expect(page).to have_text(document.original_filename)
    end
  end

  context 'when spelling search term without accent' do
    before do
      fill_in 'query', with: 'pese' # "pèse" in the document
      click_on 'Search'
    end

    it 'matches accented word anyway' do
      expect(page).to have_text(document.original_filename)
    end
  end

  context 'when searching for multiple words' do
    before do
      fill_in 'query', with: 'hipster hamster' # "pèse" in the document
      click_on 'Search'
    end

    it 'matches document with any word' do
      expect(page).to have_text(document.original_filename)
    end
  end
end

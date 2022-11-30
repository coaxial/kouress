# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searches', type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:user) { create :user }
  let!(:document) { create :document, :multisearchable, :with_accentuated_words }

  context 'when searching for one word' do
    before do
      login user

      visit home_path

      fill_in 'query', with: 'hipster'
      click_on 'Search'
    end

    it 'shows the matching documents' do
      expect(page).to have_text(document.original_filename)
    end
  end

  context 'when spelling search term without accent' do
    before do
      login user

      visit home_path

      fill_in 'query', with: 'pese' # "pèse" in the document
      click_on 'Search'
    end

    it 'matches accented word anyway' do
      expect(page).to have_text(document.original_filename)
    end
  end
end

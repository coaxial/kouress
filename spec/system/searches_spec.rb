# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searches', type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:user) { create :user }
  let!(:document) { create :multisearchable_document }

  context 'when searching for one word' do
    before do
      login user

      visit home_path

      fill_in 'query', with: 'trusting'
      click_on 'Search'
    end

    it 'shows the matching documents' do
      expect(page).to have_text('p761-thompson')
    end
  end

  pending 'drops accents from search'
  # it 'drops accents from search' do
  #   visit '/'

  #   fill_in 'Search', with: 'Hèlló'

  #   click_button 'Search'

  #   expect(page).to have_text('hello')
  # end
end

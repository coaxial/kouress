# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searches', type: :system do
  before do
    driven_by(:rack_test)
  end

  it 'drops accents from search' do
    visit '/'

    fill_in 'Search', with: 'Hèlló'

    click_button 'Search'

    expect(page).to have_text('hello')
  end
end

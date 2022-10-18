# frozen_string_literal: true

require 'capybara/dsl'

# Various helpers for feature specs
module FeatureHelper
  # See https://github.com/teamcapybara/capybara/tree/a3ff5514f40f3af0ec6655354d3596f6d9ea8964#using-the-dsl-elsewhere
  include Capybara::DSL

  def login(user)
    visit '/login'
    fill_in 'Username', with: user.username
    fill_in 'Password', with: user.password
    click_button I18n.t('sessions.new.log_in')
  end
end

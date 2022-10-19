# frozen_string_literal: true

require 'capybara/dsl'

# Various helpers for feature specs
module FeatureHelper
  # See https://github.com/teamcapybara/capybara/tree/a3ff5514f40f3af0ec6655354d3596f6d9ea8964#using-the-dsl-elsewhere
  include Capybara::DSL

  # Logs the user in
  # @param user [ActiveRecord::User] the user to login with
  def login(user)
    visit '/login'
    fill_in 'Username', with: user.username
    fill_in 'Password', with: user.password
    click_button I18n.t('sessions.new.log_in')
  end

  # Fills a form in as per attributes, then submits using the button matching submit_label
  # @param attributes [Hash<Symbol, String>] the attribute's label and its value to fill the form with
  # @param submit_label [String] the I18n.t string to find the submit button by its label
  def fill_form(attributes, submit_label)
    attributes.each do |k, v|
      fill_in k, with: v
    end

    click_button I18n.t(submit_label)
  end
end

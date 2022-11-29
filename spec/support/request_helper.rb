# frozen_string_literal: true

require 'capybara/dsl'

# Various helpers for request specs
module RequestHelper
  # See https://github.com/teamcapybara/capybara/tree/a3ff5514f40f3af0ec6655354d3596f6d9ea8964#using-the-dsl-elsewhere
  include Capybara::DSL

  # Logs the user in
  # @param user [ActiveRecord::User] the user to login with
  def login(user)
    post sessions_path, params: { username: user.username,
                                  password: user.password, }
  end
end

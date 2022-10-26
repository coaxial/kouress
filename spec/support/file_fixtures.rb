# frozen_string_literal: true

# Allow file_fixture in factories
FactoryBot::SyntaxRunner.class_eval do
  include RSpec::Rails::FileFixtureSupport
end

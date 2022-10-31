# frozen_string_literal: true

require 'capybara/rspec'
require './spec/support/feature_helper'
require './spec/support/request_helper'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true

    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.before focused: true do
    raise "Don't commit focused specs." if ENV['FORBID_FOCUSED_SPECS']
  end

  config.include FeatureHelper, type: :feature
  config.include RequestHelper, type: :request
  # TODO: clear_enqueued_jobs automatically for type: :job
  # config.include ActiveJob::TestHelper, type: :job

  config.after(:suite) { FileUtils.rm_rf(ActiveStorage::Blob.service.root) }
  # TODO: clear_enqueued_jobs automatically for type: :job
  # config.after(:suite) { clear_enqueued_jobs }
end

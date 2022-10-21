# frozen_string_literal: true

namespace :initialize do
  desc 'Creates the admin user with the default password'
  task create_admin_user: :environment do
    User.create({ username: 'admin', password: 'admin', email: 'changeme@example.org', admin: true })
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  admin           :boolean          default(FALSE)
#  email           :string           not null
#  password_digest :string
#  username        :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email     (email) UNIQUE
#  index_users_on_username  (username) UNIQUE
#
require 'rails_helper'

RSpec.describe User do
  let(:user) { create(:user) }

  it 'cannot have duplicate emails' do
    expect(described_class.create(attributes_for(:user, email: user.email)).valid?).to be false
  end

  it 'cannot have duplicate usernames' do
    expect(described_class.create(attributes_for(:user, username: user.username)).valid?).to be false
  end

  it 'cannot have empty username' do
    expect(described_class.create(attributes_for(:user, username: '')).valid?).to be false
  end

  it 'cannot have empty email' do
    expect(described_class.create(attributes_for(:user, email: '')).valid?).to be false
  end

  it 'cannot update username' do
    expect(described_class.find(user.id).update(username: 'new_username')).to be false
  end
end

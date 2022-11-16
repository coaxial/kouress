# frozen_string_literal: true

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

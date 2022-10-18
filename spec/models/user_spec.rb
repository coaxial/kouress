# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'cannot have duplicate emails' do
    user = create(:user)

    expect(described_class.create(attributes_for(:user, email: user.email)).valid?).to be false
  end

  it 'cannot have duplicate usernames' do
    user = create(:user)

    expect(described_class.create(attributes_for(:user, username: user.username)).valid?).to be false
  end

  it 'cannot have empty username' do
    expect(described_class.create(attributes_for(:user, username: '')).valid?).to be false
  end

  it 'cannot have empty email' do
    expect(described_class.create(attributes_for(:user, email: '')).valid?).to be false
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ManageUsers' do
  subject { page }

  let!(:users) { create_list(:user, 5) }
  let(:admin) { create(:admin) }

  context 'when user is an admin' do
    before do
      login admin
      visit users_path
    end

    it { is_expected.to have_text users[1].username }
  end

  context 'when user is not an admin' do
    before do
      login users[1]
      visit users_path
    end

    it { is_expected.to have_text I18n.t('users.admin_user.not_allowed') }

    it { is_expected.not_to have_text users[0].username }
  end
end

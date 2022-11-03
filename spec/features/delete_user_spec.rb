# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DeleteUsers' do
  let(:admin) { create(:admin) }
  let!(:user) { create(:user) }

  context 'when user is an admin' do
    before do
      login admin
      visit users_path
    end

    context 'when deleting a user' do
      before { click_link "delete-#{user.id}" }

      it 'can delete a user' do
        expect(page).not_to have_text(user.username)
      end

      it 'shows a confirmation' do
        expect(page).to have_text(I18n.t('users.destroy.success'))
      end
    end
  end
end

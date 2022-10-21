# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DeleteUsers', type: :feature do
  let(:admin) { create(:admin) }
  let!(:user) { create(:user) }
  let!(:deleted_user) { create(:user, deleted: true) }

  context 'when user is an admin' do
    before do
      login admin
      visit users_path
    end

    context 'when deleting a user' do
      before { click_link "delete-#{user.id}" }

      it 'can delete a user' do
        deletion_status = find("#user-#{user.id}-deleted")

        expect(deletion_status).to have_text('true')
      end

      it 'can restore a user' do
        click_link "delete-#{user.id}"
        deletion_status = find("#user-#{user.id}-deleted")

        expect(deletion_status).to have_text('false')
      end

      it 'shows a confirmation' do
        expect(page).to have_text(
          I18n.t('users.destroy.success', operation: 'deleted')
        )
      end
    end

    context 'when restoring a user' do
      before { click_link "delete-#{deleted_user.id}" }

      it 'shows a confirmation' do
        expect(page).to have_text(
          I18n.t('users.destroy.success', operation: 'restored')
        )
      end
    end
  end
end

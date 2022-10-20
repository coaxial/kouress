# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DeleteUsers', type: :feature do
  let(:admin) { create(:admin) }
  let!(:user) { create(:user) }
  let!(:deleted_user) { create(:user, is_deleted: true) }

  context 'when user is an admin' do
    before do
      login admin
      visit users_path
    end

    context 'when deleting a user' do
      before do
        click_link "delete-#{user.id}"
      end

      it 'can delete a user' do
        subject = find("#user-#{user.id}-is_deleted")

        expect(subject).to have_text('true')
      end

      it 'can restore a user' do
        click_link "delete-#{user.id}"
        subject = find("#user-#{user.id}-is_deleted")

        expect(subject).to have_text('false')
      end

      it 'shows a confirmation' do
        subject = page

        expect(subject).to have_text(I18n.t('users.destroy.success', operation: 'deleted'))
      end
    end

    context 'when restoring a user' do
      subject { page }

      before do
        # visit users_path
        click_link "delete-#{deleted_user.id}"
      end

      it 'shows a confirmation' do
        expect(subject).to have_text(I18n.t('users.destroy.success', operation: 'restored'))
      end
    end
  end
end

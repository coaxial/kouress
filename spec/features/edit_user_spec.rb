# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'EditUsers', type: :feature do
  subject { page }

  let(:submit_label) { 'shared.users.form.update' }
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  context 'when user is not an admin' do
    before do
      login user
      visit edit_user_path(user)
    end

    it { is_expected.not_to have_field('user_admin') }

    it 'can update email' do
      fill_form({ Email: 'newemail@example.org' }, submit_label)

      expect(page).to have_text(I18n.t('users.update.success'))
    end

    it 'can update password' do
      fill_form({ Password: 'evenbetterpassword' }, submit_label)

      expect(page).to have_text(I18n.t('users.update.success'))
    end
  end

  context 'when user is an admin' do
    before do
      login admin
      visit edit_user_path(user)
    end

    it { expect(subject).to have_field('user_admin') }

    it 'can update email' do
      fill_form({ Email: 'newemail@example.org' }, submit_label)

      expect(page).to have_text(I18n.t('users.update.success'))
    end

    it 'can update password' do
      fill_form({ Password: 'evenbetterpassword' }, submit_label)

      expect(User.find(user.id).authenticate('evenbetterpassword')).to be_truthy
    end

    it 'can update other attributes without clobbering password' do
      fill_form({ Email: 'changedagain@example.org' }, submit_label)

      expect(User.find(user.id).authenticate(user.password)).to be_truthy
    end
  end
end

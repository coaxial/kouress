# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'EditUsers', type: :feature do
  let(:submit_label) { 'shared.users.form.update' }

  context 'when user is not an admin' do
    before do
      user = create(:user)
      login(user)
      visit edit_user_path(user)
    end

    it 'doesnt show is_admin status' do
      expect(page).not_to have_field('user_is_admin')
    end

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
      admin = create(:admin)
      @user = create(:user)
      login(admin)
      visit edit_user_path(@user)
    end

    it 'can update is_admin status' do
      expect(page).to have_field('user_is_admin')
    end

    it 'can update email' do
      fill_form({ Email: 'newemail@example.org' }, submit_label)

      expect(page).to have_text(I18n.t('users.update.success'))
    end

    it 'can update password' do
      fill_form({ Password: 'evenbetterpassword' }, submit_label)

      expect(User.find(@user.id).authenticate('evenbetterpassword')).to be_truthy
    end

    it 'can update other attributes without clobbering password' do
      user = create(:user)
      visit edit_user_path(user)

      fill_form({ Email: 'changedagain@example.org' }, submit_label)

      expect(User.find(user.id).authenticate(user.password)).to be_truthy
    end
  end
end

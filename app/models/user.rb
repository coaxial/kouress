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
class User < ApplicationRecord
  has_secure_password

  def permitted_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation)
  end

  validates :email, :username, uniqueness: true, presence: true
  validates_with ImmutableUsernameValidator, fields: :username, on: :update
end

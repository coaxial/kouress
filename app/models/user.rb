class User < ApplicationRecord
    has_secure_password

    attr_accessible :email, :username, :password_confirmation

    validates_uniqueness: :email, :username
end

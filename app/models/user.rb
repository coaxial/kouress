class User < ApplicationRecord
    has_secure_password

    def permitted_params
        params.require(:user).permit(:email, :username, :password, :password_confirmation)
    end

    validates :email, :username, uniqueness: true
end

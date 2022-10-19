# frozen_string_literal: true

# Ensures usernames are immutable.
class ImmutableUsernameValidator < ActiveModel::Validator
  def validate(record)
    user = User.find(record.id)

    record.errors.add :username, I18n.t('users.validators.immutable_username') unless user.username == record.username
  end
end

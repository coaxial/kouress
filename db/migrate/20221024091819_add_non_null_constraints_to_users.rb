# frozen_string_literal: true

class AddNonNullConstraintsToUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_null :users, :username, false
    change_column_null :users, :email, false
  end
end

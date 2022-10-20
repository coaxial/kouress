# frozen_string_literal: true

class AddIsDeletedFlagToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :is_deleted, :boolean, default: false
  end
end

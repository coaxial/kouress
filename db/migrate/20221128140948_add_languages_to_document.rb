# frozen_string_literal: true

class AddLanguagesToDocument < ActiveRecord::Migration[7.0]
  def change
    change_table :documents do |t|
      t.belongs_to :language
    end
  end
end

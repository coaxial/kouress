# frozen_string_literal: true

class CreatePages < ActiveRecord::Migration[7.0]
  def change
    create_table :pages do |t|
      t.references :document, null: false, foreign_key: true
      t.integer :page_no

      t.timestamps
    end
  end
end

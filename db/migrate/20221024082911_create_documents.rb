# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents do |t|
      t.string :original_filename
      t.integer :size
      t.string :mimetype

      t.timestamps
    end
    add_index :documents, :original_filename
  end
end

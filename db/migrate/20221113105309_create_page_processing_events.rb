# frozen_string_literal: true

class CreatePageProcessingEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :page_processing_events do |t|
      t.references :page, null: false, foreign_key: true
      t.string :state

      t.timestamps
    end
  end
end

# frozen_string_literal: true

class CreateDocumentProcessingEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :document_processing_events do |t|
      t.references :document, null: false, foreign_key: true
      t.string :state

      t.timestamps
    end
  end
end

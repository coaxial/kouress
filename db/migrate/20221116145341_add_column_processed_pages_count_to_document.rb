# frozen_string_literal: true

class AddColumnProcessedPagesCountToDocument < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :processed_pages_count, :integer, default: 0, null: false
  end
end

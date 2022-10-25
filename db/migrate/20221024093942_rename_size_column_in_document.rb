# frozen_string_literal: true

class RenameSizeColumnInDocument < ActiveRecord::Migration[7.0]
  def change
    rename_column :documents, :size, :size_bytes
  end
end

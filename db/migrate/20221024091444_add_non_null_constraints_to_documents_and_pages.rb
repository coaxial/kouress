# frozen_string_literal: true

class AddNonNullConstraintsToDocumentsAndPages < ActiveRecord::Migration[7.0]
  def change
    change_column_null :documents, :original_filename, false
    change_column_null :documents, :size, false
    change_column_null :documents, :mimetype, false

    change_column_null :pages, :page_no, false
  end
end

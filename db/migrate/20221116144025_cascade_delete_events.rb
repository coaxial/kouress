# frozen_string_literal: true

class CascadeDeleteEvents < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :document_processing_events, :documents
    remove_foreign_key :page_processing_events, :pages
    remove_foreign_key :pages, :documents

    add_foreign_key :document_processing_events, :documents, on_delete: :cascade
    add_foreign_key :page_processing_events, :pages, on_delete: :cascade
    add_foreign_key :pages, :documents, on_delete: :cascade
  end
end

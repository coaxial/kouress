# frozen_string_literal: true

class AddDocumentIdToPageSearchable < ActiveRecord::Migration[7.0]
  def change
    add_reference :pg_search_documents, :document, index: true
  end
end

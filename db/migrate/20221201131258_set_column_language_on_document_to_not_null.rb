# frozen_string_literal: true

class SetColumnLanguageOnDocumentToNotNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :documents, :language_id, false
  end
end

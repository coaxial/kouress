# frozen_string_literal: true

class AddTextToPages < ActiveRecord::Migration[7.0]
  def change
    add_column :pages, :text, :text
  end
end

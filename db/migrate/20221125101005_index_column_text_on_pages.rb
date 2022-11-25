# frozen_string_literal: true

class IndexColumnTextOnPages < ActiveRecord::Migration[7.0]
  def change
    add_index :pages, :text
  end
end

# frozen_string_literal: true

class RenamePageNoToPageNumInPages < ActiveRecord::Migration[7.0]
  def change
    rename_column :pages, :page_no, :page_num
  end
end

# frozen_string_literal: true

class SiteController < ApplicationController
  def home
    @document = Document.new
    @documents = Document.all.order(updated_at: :desc).kpage(params[:kpage])
    @languages = Language.all.sort_by(&:fulltext_name)
  end
end

# frozen_string_literal: true

class SiteController < ApplicationController
  def home
    # TODO: paginate this
    @document = Document.new
    @documents = Document.all
    @languages = Language.all.sort_by(&:fulltext_name)
  end
end

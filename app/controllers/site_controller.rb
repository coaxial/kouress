# frozen_string_literal: true

class SiteController < ApplicationController
  def home
    @document = Document.new
    @documents = Document.all
  end
end

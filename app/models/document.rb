# frozen_string_literal: true

class Document < ApplicationRecord
  has_many :pages, dependent: :delete_all
end

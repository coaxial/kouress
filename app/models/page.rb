# frozen_string_literal: true

class Page < ApplicationRecord
  belongs_to :document
  has_one_attached :image
  default_scope { order(:page_num) }
end

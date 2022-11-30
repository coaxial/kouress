# frozen_string_literal: true

class Language < ApplicationRecord
  ISO_CODES = ISO_639::ISO_639_2.map(&:alpha3)

  validates :iso_code, presence: true, uniqueness: true, inclusion: { in: ISO_CODES }

  def to_s
    iso_code
  end

  def fulltext_name
    ISO_639.find(iso_code).english_name
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: languages
#
#  id                            :bigint           not null, primary key
#  iso_code(ISO 639 alpha3 code) :enum             default("eng"), not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_languages_on_iso_code  (iso_code) UNIQUE
#
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

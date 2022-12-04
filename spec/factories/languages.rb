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
FactoryBot.define do
  factory :language do
    iso_code { 'eng' }
  end
end

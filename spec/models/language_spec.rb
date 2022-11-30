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
require 'rails_helper'

RSpec.describe Language, type: :model do
  let(:language) { create :language }

  describe '#to_s' do
    it 'returns the iso_code' do
      expect(language.to_s).to eq(language.iso_code)
    end
  end

  describe '#fulltext_name' do
    it 'returns the english name' do
      english_name = ISO_639.find(language.iso_code).english_name
      expect(language.fulltext_name).to eq(english_name)
    end
  end
end

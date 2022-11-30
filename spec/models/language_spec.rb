# frozen_string_literal: true

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

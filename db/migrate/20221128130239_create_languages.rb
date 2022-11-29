# frozen_string_literal: true

class CreateLanguages < ActiveRecord::Migration[7.0]
  def change
    create_enum :iso_639_alpha3_codes, alpha3_codes

    create_table :languages do |t|
      t.enum :iso_code, enum_type: :iso_639_alpha3_codes, default: english, comment: 'ISO 639-2 alpha3 code', index: { unique: true }, null: false
      t.timestamps
    end
  end

  private

  def alpha3_codes
    ISO_639::ISO_639_2.map(&:alpha3)
  end

  def english
    ISO_639.find('en').alpha3
  end
end

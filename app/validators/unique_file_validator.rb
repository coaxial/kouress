# frozen_string_literal: true

# Checks that a file isn't a duplicate of another file.
class UniqueFileValidator < ActiveModel::Validator
  def validate(record)
    return unless ActiveStorage::Blob.find_by(checksum: record.file.checksum)

    record.errors.add :file,
                      I18n.t('documents.validators.unique_doc.exists')
  end
end

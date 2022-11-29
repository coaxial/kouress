# frozen_string_literal: true

PgSearch.multisearch_options = {
  ignoring: :accents,
  using: {
    # TODO: if all documents are in one language, allow for configuring that
    # language by the user and use it here.
    tsearch: { dictionary: 'simple' },
  },
}

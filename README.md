# Kouress

Paperless document store and search.

## Requirements

### Ruby version

The version is specified in `.ruby-version`, currently ruby-3.1.2

### NodeJS version

The version is specified in `.nvmrc`, currently 16.17.1

## Development

### Setup dependencies

- Install the required nodejs version if not already present with `nvm install 16.17.1`
- Switch nodejs versions with `nvm use`
- Enable `corepack` with `corepack enable`
- Install JS dependencies: `yarn install`
- Install libvips: `apt install libvips`

### Run the development server and redis

- `./bin/dev` (watch out for error messages when starting the server about `yarn`, `tailwind`, or `esbuild` commands missing. See `Setup dependencies` steps above.
- `bundle exec guard` for RuboCop and RSpec on watch.

### Debugging

Use `debugger` anywhere to start an interactive console in the code's context.

For views, `console` loads an interactive console at the bottom of the page in the view's context.

Tests can be run individually by adding the `:focus` tag. Rubocop will complain without autocorrecting, but that will fail the CI build if committed and pushed.

```ruby
it 'tests a thing', :focus do
end
```

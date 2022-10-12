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
- Install turbo-rails: `bundle install && rails turbo:install` (`rails turbo:install:redis`?)
- Install stimulus: `rails stimulus:install`

> These steps might be optional, maybe they aren't needed anymore since I set it all up once.

### Run the development server

`./bin/dev` (watch out for error messages when starting the server about `yarn`, `tailwind`, or `esbuild` commands missing. See steps above.

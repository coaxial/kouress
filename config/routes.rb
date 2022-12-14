# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  # TODO: allow this for the admin in all envs
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?
  get 'home', to: 'site#home', as: 'home'
  get 'new_user', to: 'users#new', as: 'new_user'
  get 'login', to: 'sessions#new', as: 'login'
  delete 'logout', to: 'sessions#destroy', as: 'logout'
  get 'logout', to: 'sessions#destroy'

  resources :users
  resources :sessions
  resources :documents
  resources :pages

  root 'site#home'
end

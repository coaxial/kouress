# frozen_string_literal: true

Rails.application.routes.draw do
  get 'home', to: 'site#home', as: 'home'
  get 'new_user', to: 'users#new', as: 'new_user'
  get 'login', to: 'sessions#new', as: 'login'
  delete 'logout', to: 'sessions#destroy', as: 'logout'
  get 'logout', to: 'sessions#destroy'

  resources :users
  resources :sessions
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'site#home'
end

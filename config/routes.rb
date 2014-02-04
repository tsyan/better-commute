BetterCommute::Application.routes.draw do

  resources :users

  resources :journeys do
    resources :routes
  end

  root 'journeys#new'

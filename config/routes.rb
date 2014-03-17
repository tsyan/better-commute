BetterCommute::Application.routes.draw do

  root 'journeys#new'

  resources :journeys, only: [:new, :create, :show] do
    resources :routes, only: [:index]
  end

  patch 'journeys/:id' => 'journeys#create'
  put 'journeys/:id' => 'journeys#create'

end

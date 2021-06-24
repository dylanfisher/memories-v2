Rails.application.routes.draw do
  # Public
  root to: 'memories#index'

  resources :memories, only: [:index, :show]

  get 'screensaver', to: 'screensaver#index'
  get 'full-mode', to: 'options#full'

  # Admin
  namespace :admin do
    resources :locations
    resources :memories
  end
end

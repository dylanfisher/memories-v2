Rails.application.routes.draw do
  # Public
  root to: 'memories#index'

  resources :memories, only: [:index, :show]
  resources :shared_links, only: [:show], path: 'shared', controller: 'memories', defaults: { shared: true }

  get 'screensaver', to: 'screensaver#index'
  get 'full-mode', to: 'options#full'

  # Admin
  namespace :admin do
    resources :locations
    resources :memories
    resources :media_items, except: [:show], path: 'media-items' do
      post 'update_multiple', on: :collection
      post 'reprocess', on: :member
      post 'hide_from_public', on: :member
      post 'show_to_public', on: :member
    end
  end
end

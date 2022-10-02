Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :years, except: %i[show]
  resources :members, shallow: true do
    resources :addresses, except: %i[index show], controller: 'members/addresses'
    resources :users, except: %i[index show], controller: 'members/users'
  end

  resources :events
  resources :payments
  resources :attendances, only: %i[edit update]

  # Defines the root path route ("/")
  root 'members#index'
end

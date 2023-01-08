Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :years, except: %i[show]
  resources :members do
    resources :addresses, except: %i[index show], controller: 'members/addresses'
    resources :users, except: %i[index show], controller: 'members/users'
  end

  get 'statistics/members'
  get 'exports/members'
  resources :mails, only: %i[index]

  resources :events
  resources :payments
  resources :payment_histories, except: %i[show]
  resources :attendances, only: %i[edit update]

  # Defines the root path route ("/")
  root 'members#index'
end

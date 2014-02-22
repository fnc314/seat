Seat::Application.routes.draw do
  devise_for :admins
  root :to => "home#index"
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users

end
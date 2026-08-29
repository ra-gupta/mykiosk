Rails.application.routes.draw do
  resource :session
  resource :registration, only: %i[ new create ]
  resource :phone_verification, only: :create
  resources :passwords, param: :token

  resources :products, only: :index
  get "owner/orders", to: "owner#orders", as: :owner_orders
  resources :orders, only: %i[ index show new create ]

  namespace :api do
    namespace :v1 do
      resource :session, only: %i[ create destroy ]
      resource :registration, only: :create
      resource :phone_verification, only: :create
      resources :device_tokens, only: %i[ create destroy ]
      resources :products, only: :index
      resources :orders, only: %i[ index show create ]
    end
  end

  resource :cart, only: %i[ show destroy ]
  patch "cart/:product_id" => "carts#update", as: :cart_item
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "products#index"
end

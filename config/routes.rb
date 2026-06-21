Rails.application.routes.draw do
  devise_for :users

  # Public marketing site
  root "pages#home"
  get "about", to: "pages#about"
  get "services", to: "pages#services"
  get "gallery", to: "pages#gallery"
  get "contact", to: "pages#contact"

  # Lead submission (public)
  resources :leads, only: [:create] do
    collection do
      post :quote
    end
  end

  # Admin namespace
  namespace :admin do
    root "dashboard#index"

    resources :leads do
      member do
        patch :transition
        patch :mark_spam
        patch :unmark_spam
        patch :archive
        patch :restore
        patch :assign
      end
      resources :notes, only: [:create, :destroy]
    end

    resources :projects do
      member do
        patch :transition
      end
      resources :notes, only: [:create, :destroy]
      resources :order_forms, except: [:index] do
        member do
          patch :submit_order
          patch :confirm_order
          patch :receive_order
        end
      end
      resources :invoices, except: [:index] do
        member do
          patch :send_invoice
          patch :record_payment
        end
      end
    end

    resources :notification_preferences, only: [:index, :update]
    resources :testimonials
    resources :gallery_images
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end

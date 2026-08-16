Rails.application.routes.draw do
  devise_for :users

  # Public marketing site
  root "pages#home"
  get "about", to: "pages#about"
  # Individual service pages
  scope :services, as: :services do
    get "/",                              to: redirect("/"), as: :all
    get "cabinet-refacing",               to: "services#cabinet_refacing",        as: :cabinet_refacing
    get "cabinet-repainting",             to: "services#cabinet_repainting",      as: :cabinet_repainting
    get "cabinet-installation",           to: "services#cabinet_installation",    as: :cabinet_installation
    get "cabinet-customization-and-repair", to: "services#cabinet_customize_repair", as: :cabinet_customize_repair
    get "custom-closets-and-pantries",    to: "services#custom_closets",          as: :custom_closets
    get "countertops",                    to: "services#countertops",             as: :countertops
  end
  get "gallery", to: "pages#gallery"
  get "contact", to: "pages#contact"
  get "resources", to: "pages#resources"
  get "sitemap", to: "pages#sitemap", defaults: { format: :xml }, as: :sitemap

  # Lead submission (public)
  resources :leads, only: [:create] do
    collection do
      post :quote
    end
  end

  # Admin namespace
  namespace :admin do
    root "dashboard#index"

    resource :account, only: [:show, :update], controller: "account"
    get "search", to: "search#index"

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

    resources :order_forms, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
      member do
        patch :submit_order
        patch :confirm_order
        patch :receive_order
      end
    end
    resources :invoices, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
      member do
        patch :send_invoice
        patch :record_payment
      end
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
    resources :gallery_images do
      collection do
        get :bulk_new
        post :bulk_create
      end
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end

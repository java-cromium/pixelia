require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  # ── Sidekiq Web UI (super_admin only) ──────────────────────────
  authenticate :user, ->(u) { u.super_admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # ── Public Marketing Site (www) ──────────────────────────────────
  constraints subdomain: "www" do
    scope module: "marketing" do
      root to: "pages#home", as: :marketing_root
      get "services",   to: "pages#services"
      get "contact",    to: "pages#contact"
      get "servicios/diseno-web",        to: "pages#servicio_diseno_web",        as: :servicio_diseno_web
      get "servicios/ecommerce",         to: "pages#servicio_ecommerce",         as: :servicio_ecommerce
      get "servicios/gestion-integral",  to: "pages#servicio_gestion_integral",  as: :servicio_gestion_integral
      resources :leads, only: [:create]
    end
  end

  # ── Self-Serve Portal (app subdomain — production) ──────────────
  constraints subdomain: "app" do
    scope module: "portal" do
      root to: "dashboard#index", as: nil
      resources :ecommerce_stores, only: [:index, :show], as: nil
      resources :sites, only: [:index, :show], as: nil do
        resource :domain, only: [:show, :create, :destroy], controller: "domains"
        resources :pages, controller: "pages", as: nil do
          member do
            get :editor
            get :content
            put :content
          end
        end
        member do
          get :build_wizard, controller: "sites", action: "build_wizard"
          post :generate, controller: "sites", action: "generate"
          post :generate_content, controller: "sites", action: "generate_content"
        end
      end

      get  "billing",          to: "billing#show",     as: nil
      post "billing/checkout", to: "billing#checkout", as: nil
      get  "billing/success",  to: "billing#success",  as: nil
      post "billing/portal",   to: "billing#portal",   as: nil

      get  "settings", to: "settings#show", as: nil
      patch "settings", to: "settings#update", as: nil

      # Google Ads
      resources :google_campaigns, controller: "google_campaigns", as: nil do
        member do
          post :sync
          post :pause
          post :enable
        end
      end
      get  "auth/google_ads/callback", to: "google_ads_oauth#callback", as: nil
      get  "auth/google_ads/failure",  to: "google_ads_oauth#failure", as: nil
      delete "google_ads/disconnect",  to: "google_ads_oauth#destroy", as: nil

      # Meta Ads
      resources :meta_campaigns, controller: "meta_campaigns", as: nil do
        member do
          post :sync
          post :pause
          post :enable
        end
      end
      get  "auth/meta_ads/callback", to: "meta_ads_oauth#callback", as: nil
      get  "auth/meta_ads/failure",  to: "meta_ads_oauth#failure", as: nil
      delete "meta_ads/disconnect",  to: "meta_ads_oauth#destroy", as: nil

      # AI Chat
      resources :chats, controller: "chats", as: nil do
        member { post :message }
      end
    end
  end

  # ── Admin Panel (super_admin only) ─────────────────────────────
  namespace :admin do
    root to: "dashboard#index"
    resources :accounts
    resources :users
    resources :leads, only: [:index, :show, :update, :destroy]
    resources :ecommerce_stores
    resources :sites do
      resources :pages, except: [:index, :show] do
        member do
          get :editor
          get :content
          put :content
        end
      end
    end
  end

  # ── Published Site Preview ─────────────────────────────────────
  get "preview/:subdomain", to: "sites#show", as: :site_preview
  get "preview/:subdomain/:slug", to: "sites#show"

  # ── Stripe Webhooks ────────────────────────────────────────────
  post "webhooks/stripe", to: "webhooks/stripe#create"

  # Default root (fallback for localhost without subdomain)
  scope module: "portal", as: "portal" do
    root to: "dashboard#index"
    resources :ecommerce_stores, only: [:index, :show]
    resources :sites, only: [:index, :show] do
      resource :domain, only: [:show, :create, :destroy], controller: "domains"
      resources :pages, controller: "pages" do
        member do
          get :editor
          get :content
          put :content
        end
      end
      member do
        get :build_wizard, controller: "sites", action: "build_wizard"
        post :generate, controller: "sites", action: "generate"
        post :generate_content, controller: "sites", action: "generate_content"
      end
    end

    get  "billing",          to: "billing#show"
    post "billing/checkout", to: "billing#checkout"
    get  "billing/success",  to: "billing#success"
    post "billing/portal",   to: "billing#portal"

    get   "settings", to: "settings#show"
    patch "settings", to: "settings#update"

    # Google Ads
    resources :google_campaigns, controller: "google_campaigns" do
      member do
        post :sync
        post :pause
        post :enable
      end
    end
    get  "auth/google_ads/callback", to: "google_ads_oauth#callback", as: :google_ads_callback
    get  "auth/google_ads/failure",  to: "google_ads_oauth#failure", as: :google_ads_failure
    delete "google_ads/disconnect",  to: "google_ads_oauth#destroy", as: :google_ads_disconnect

    # Meta Ads
    resources :meta_campaigns, controller: "meta_campaigns" do
      member do
        post :sync
        post :pause
        post :enable
      end
    end
    get  "auth/meta_ads/callback", to: "meta_ads_oauth#callback", as: :meta_ads_callback
    get  "auth/meta_ads/failure",  to: "meta_ads_oauth#failure", as: :meta_ads_failure
    delete "meta_ads/disconnect",  to: "meta_ads_oauth#destroy", as: :meta_ads_disconnect

    # AI Chat
    resources :chats, controller: "chats" do
      member { post :message }
    end
  end

  scope module: "marketing" do
    get "services",   to: "pages#services"
    get "contact",    to: "pages#contact"
    get "servicios/diseno-web",        to: "pages#servicio_diseno_web"
    get "servicios/ecommerce",         to: "pages#servicio_ecommerce"
    get "servicios/gestion-integral",  to: "pages#servicio_gestion_integral"
    resources :leads, only: [:create]
  end
  root to: "marketing/pages#home"
end

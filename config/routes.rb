require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users

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

  # ── Client Portal & 360 Tool (app) ──────────────────────────────
  constraints subdomain: "app" do
    scope module: "portal" do
      root to: "dashboard#index", as: :portal_root
      resources :projects, only: [:index, :show]
      resources :ecommerce_stores, only: [:index, :show]
    end
  end

  # ── Admin Panel (super_admin only) ─────────────────────────────
  namespace :admin do
    root to: "dashboard#index"
    resources :clients
    resources :users
    resources :projects
    resources :leads, only: [:index, :show, :update, :destroy]
    resources :ecommerce_stores
  end

  # Default root (fallback for localhost without subdomain)
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

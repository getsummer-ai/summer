# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
             only: :omniauth_callbacks,
             controllers: {
               omniauth_callbacks: 'users/omniauth_callbacks',
             }

  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    devise_for :users,
               skip: :omniauth_callbacks,
               controllers: {
                 registrations: 'users/registrations',
                 sessions: 'users/sessions',
                 passwords: 'users/passwords',
               }
    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    is_playground_mode = Rails.configuration.summer[:IS_PLAYGROUND]

    root 'private/app#index'

    scope '/', module: 'private' do
      get 'app/(:id)', to: 'app#index', as: 'user_app'
      resources :projects, param: :project_id, only: [:new, :create, :destroy] do
        member do
          get :setup
          put :guidelines, action: :update_guidelines
          put :appearance, action: :update_appearance
          get :knowledge
        end
      end
      resources :projects, only: [] do
        resources :pages, param: :page_id, only: %i[index update show] do
          member do
            post 'summary/refresh', action: :summary_refresh
            post('summary/admin-delete', action: :summary_admin_delete) if is_playground_mode
            resources :products, module: 'pages', only: %i[new create edit update destroy], as: 'page_product'
          end
        end
        resources :actions, only: %i[index update]
        resources :products, only: %i[new create edit update destroy]
        resources :paths, only: %i[new create edit update destroy]
        resource :domain_alias, except: %i[create new show]
        resources :payments, only: %i[create] do
          collection do
            post :subscription
            get :success
            get :cancel
            get :return

            if is_playground_mode
              post :admin_delete_subscription
              post :admin_suspend_project
            end
          end
        end
        resources :settings, only: [:index]
      end

      resources :billing, only: %i[index]
    end

    namespace :webhooks do
      post '/stripe', to: 'stripe#webhook'
    end

    unless Rails.env.production?
      get '/about', to: 'pages#about', as: 'about'
      get '/homepage', to: 'pages#homepage', as: 'homepage'
      get '/new-year-celebrations', to: 'pages#new_year_celebration', as: 'new_year_celebrations'
      get '/how-to-make-contracts-more-human',
          to: 'pages#how_to_make_contracts_more_human',
          as: 'how_to_make_contracts_more_human'

      resources :modals, only: [] do
        collection do
          get 'login'
          get 'sign_up'
          get 'restore_password'
        end
      end
    end
  end

  get 'health-check', to: ->(_env) { [200, {}, ['OK']] }

  namespace :api do
    namespace :v1 do
      get 'button/settings', to: 'button#settings'
      post 'button/init', to: 'button#init'
      namespace :pages do
        get ':page_id/summary', to: 'summary#stream'
        post ':page_id/subscribe', to: 'users#subscribe'
        get ':page_id/products', to: 'products#show'
        post ':page_id/products/:uuid/click', to: 'products#click'
      end
    end
  end

  authenticate :user, ->(user) { user&.is_admin? } do
    mount GoodJob::Engine => 'good_jobs'
    mount Avo::Engine, at: Avo.configuration.root_path

    namespace :admin do
      resources :emails, only: [:index, :show] do
        get :preview, on: :member
      end
      resources :users, only: [:index] do
        post :impersonate, on: :member
        post :stop_impersonating, on: :collection
      end
    end
  end

  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end

if defined? Avo
  Avo::Engine.routes.draw do
    get "dashboard", to: "tools#dashboard", as: :dashboard
  end
end

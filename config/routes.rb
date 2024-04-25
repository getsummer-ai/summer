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

    root 'private/app#index'

    scope '/app', module: 'private' do
      get '/', to: 'app#index', as: 'user_app'
      resources :projects, param: :project_id, only: [:new, :create, :destroy] do
        member do
          get :setup
          put :guidelines, action: :update_guidelines
          put :appearance, action: :update_appearance
          get :knowledge
        end
      end
      resources :projects, only: [] do
        resources :pages, only: %i[index update show] do
          member do
            get :summary
            post 'summary/refresh', action: :summary_refresh
          end
        end
        resources :actions, only: %i[index update]
        resources :products, only: %i[new create edit update destroy]
        resources :paths, only: %i[new create edit update destroy]
        resources :payments, only: %i[create] do
          collection do
            get :success
            get :cancel
            get :return

            if ENV.fetch('STRIPE_TEST_ENVIRONMENT', 'false') == 'true'
              post :admin_delete_subscription
              post :admin_suspend_project
            end
          end
        end
        resources :settings, only: [:index]
      end

      resources :billing, only: %i[index]
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
    # mount Avo::Engine, at: '/avo'
    # mount Avo::Engine => '/avo'
    mount Avo::Engine, at: Avo.configuration.root_path
  end

  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end

if defined? Avo
  Avo::Engine.routes.draw do
    get "dashboard", to: "tools#dashboard", as: :dashboard
  end
end

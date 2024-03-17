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

    root 'pages#about'
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

    scope '/app', module: 'private' do
      get '/', to: 'app#index', as: 'user_app'
      resources :projects, param: :project_id, except: [:index] do
        member do
          get :setup
          get :knowledge
        end
      end
      resources :projects, only: [] do
        resources :articles, only: %i[index show edit update]
        resources :pages, only: %i[index update show]
        resources :paths, only: %i[new create edit update destroy]
        resources :settings, only: [:index]
      end
    end
  end

  namespace :api do
    namespace :v1 do
      get 'button/version', to: 'button#version'
      post 'button/init', to: 'button#init'
      get 'summary/stream', to: 'summary#stream'
      resources :projects, only: %i[show]
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

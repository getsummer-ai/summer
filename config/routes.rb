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

    resources :modals, only: [] do
      collection do
        get 'login'
        get 'sign_up'
        get 'restore_password'
      end
    end

    scope '/app', module: 'private' do
      get '/', to: 'app#index', as: 'user_app'
      resources :projects do
        resources :articles, only: %i[index show edit update]
      end
    end
  end

  namespace :api do
    namespace :v1 do
      get 'button/init', to: 'button#init'
      get 'button/summary', to: 'button#summary'
      get 'button/version', to: 'button#version'
      resources :projects, only: %i[show]
    end
  end

  authenticate :user, ->(user) { user&.is_admin? } do
    mount GoodJob::Engine => 'good_jobs'
    # mount Avo::Engine, at: '/avo'
    mount Avo::Engine => '/avo'
  end

  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end

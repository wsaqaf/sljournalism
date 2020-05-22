require 'api_constraints'

Rails.application.routes.draw do
  get 'about/index'
  get 'home/index'
  get 'tags/:tag', to: 'claims#index', as: :tag

  resources :affiliations
  resources :resources
  resources :claims

  devise_for :users

  devise_scope :user do
    get '/users/' => 'claims#index'
  end

  match 'admin/users/edit' => 'users#edit', :as => :edit_user, via: [:get]

  namespace :admin do
    resources :resources
    resources :users
    root 'users#index'
  end

  resources :resources do
      member do
        post :export
      end
  end

  resources :claims do
    member do
      post :export
    end
    resources :claim_reviews do
      resources :steps, only: [:show, :update], controller: 'claim_review/steps'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :srcs do
    member do
      post :export
    end
    resources :src_reviews do
      resources :steps, only: [:show, :update], controller: 'src_review/steps'
    end
  end

  resources :media do
    member do
      post :export
    end
    resources :medium_reviews do
      resources :steps, only: [:show, :update], controller: 'medium_review/steps'
    end
  end

  root 'home#index'

  resources :claims do
    get :autocomplete_user_affiliation, on: :collection
  end

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :claims
      resources :claim_reviews
      resource :sessions, only: [:create, :destroy]
    end
  end
end

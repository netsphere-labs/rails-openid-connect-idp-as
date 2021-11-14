# -*- coding:utf-8 -*-

# 単数形の resource コマンドでも、コントローラ名が複数形になってしまう。
# => controller: オプションでクラス名を指定すればよい. 
Rails.application.routes.draw do
  resource :session,   only: :destroy
  resource :dashboard, only: :show

  # Relying Party (RP) - テナントにぶら下がる
  resources :clients, except: :show

  # テナントにぶら下がる
  resources :authorizations, only: [:new, :create]

  # テナントユーザのログインのため
  namespace :connect do
    resource :facebook, only: :show

    # Client (RP) として接続
    resource :google,   only: [:create, :show]

    resource :client,   only: :create
  end

  root to: 'top#index'

  # 'webfinger', 'openid-configuration'
  get   '.well-known/:id', to: 'discovery#show'
  
  match 'user_info',       to: 'user_info#show', :via => [:get, :post]

  post  'access_tokens', to: proc { |env| TokenEndpoint.new.call(env) }
  get   'jwks.json',     to: proc { |env| 
                                [200, 
                                 {'Content-Type' => 'application/json'}, 
                                 [IdToken.config[:jwk_set].to_json]] }

  # For details on the DSL available within this file, 
  # see https://guides.rubyonrails.org/routing.html
end

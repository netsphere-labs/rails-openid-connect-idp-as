# -*- coding:utf-8 -*-

# Tip:
# 単数形の resource コマンドでも、コントローラ名が複数形になってしまう。
# => controller: オプションでクラス名を指定すればよい.

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest


  # 管理者用機能 #################################################
  
  # Log out
  delete 'session', to: 'session#destroy'

  # List of RP
  get 'dashboard', to: 'dashboard#show'

  # Relying Party (RP) - テナントが管理する
  resources :clients

  # テナントユーザのログインのため
  namespace :connect do
    resource :facebook, only: [:show], controller: 'facebook' 

    # Client (RP) として接続
    resource :google, only: [:create, :show], controller: 'google'

    # Relying Party (RP) の動的登録
    # Spec: OpenID Connect Dynamic Client Registration 1.0
    #       https://openid.net/specs/openid-connect-registration-1_0.html
    # -> これが必要になるユースケースが全く思い当たらない。
    # 関連仕様:
    #   RFC 7591 (July 2015) OAuth 2.0 Dynamic Client Registration Protocol
    #      -> Appendix A.  Use Cases があるが、でも、必要かな?
    # Google も Azure AD もサポートしていない。
    # -> この人も同意見
    #    https://oauth.jp/blog/2016/02/24/is-openid-connect-far-from-oauth2/
    #resource :client,   only: :create
  end

  # 払い出されるユーザ 
  resources :fake_users

  root to: 'top#index'


  # IdP 機能 #####################################################

  # 認可エンドポイント. 登録された RP がアクセスできる
  resources :authorizations, only: [:new, :create]

  # 'webfinger', 'openid-configuration'
  get   '.well-known/:id', to: 'discovery#show'

  # Token Endpoint
  # The Authorization Code Flow: アクセストークンと id token を返す.
  post  'access_tokens', to: 'tokens#index'

  # UserInfo Endpoint
  match 'user_info',       to: 'user_info#show', :via => [:get, :post]

  get   'jwks.json',     to: proc { |env| 
                                [200, 
                                 {'Content-Type' => 'application/json'}, 
                                 [IdToken.config[:jwk_set].to_json]] }

  # For details on the DSL available within this file, 
  # see https://guides.rubyonrails.org/routing.html
end

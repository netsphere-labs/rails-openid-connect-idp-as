# -*- coding:utf-8 -*-

# 単数形の resource コマンドでも、コントローラ名が複数形になってしまう。
# => controller: オプションでクラス名を指定すればよい. 
Rails.application.routes.draw do
  # Log out
  delete 'session', to: 'session#destroy'
  
  get 'dashboard', to: 'dashboard#show'

  # Relying Party (RP) - テナントにぶら下がる
  resources :clients, except: :show

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

  # テナントにぶら下がる
  resources :authorizations, only: [:new, :create]

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

# -*- coding:utf-8 -*-

=begin
NotFound の正しい投げ方

×間違い raise HttpError::NotFound
×間違い render status: 404 などなど
次とする解説も多いが, 実は捕捉できていない。
```
  rescue_from ActionController::RoutingError, with:メソッド名
```
      
次が正解. 単に投げればよい. 引数は `message, efailures = []`
```
  raise ActionController::RoutingError.new('unknown ' + params[:id])
```

Production 環境では自動的に 404 にしてくれる。`ActiveRecord::RecordNotFound` も同様。
See https://github.com/rails/rails/blob/6-1-stable/actionpack/lib/action_dispatch/middleware/exception_wrapper.rb
    https://github.com/rails/rails/blob/6-1-stable/activerecord/lib/active_record/railtie.rb
=end


class DiscoveryController < ApiController
  #skip_before_action :authorization
  
  def show
    case params[:id]
    when 'webfinger'
      # GET /.well-known/webfinger
      # spec: OpenID Connect Discovery 1.0
      #       https://openid.net/specs/openid-connect-discovery-1_0.html
      # -> issuer を得るためのもの。
      webfinger_discovery
    when 'openid-configuration'
      # <issuer>/.well-known/openid-configuration
      openid_configuration
    else
      raise ActionController::RoutingError.new('unknown ' + params[:id])
    end
  end


private

  def webfinger_discovery
    jrd = {
      links: [{
        rel: OpenIDConnect::Discovery::Provider::Issuer::REL_VALUE,
        href: IdToken.config[:issuer]
      }]
    }
    jrd[:subject] = params[:resource] if params[:resource].present?
    # config/initializers/mime_types.rb で定義。Rails5 で書き方が変わった
    render json: jrd, content_type: Mime[:jrd]
  end


  def openid_configuration
    config = OpenIDConnect::Discovery::Provider::Config::Response.new(
      issuer: IdToken.config[:issuer],
      authorization_endpoint: new_authorization_url,
      token_endpoint: access_tokens_url,
      userinfo_endpoint: user_info_url,
      jwks_uri: IdToken.config[:jwks_uri],
      #registration_endpoint: connect_client_url,  ● TODO: 復活する
      #end_session_endpoint: ...  ● TODO: シングルログアウト (SLO) の実装
      scopes_supported: Scope.all.collect(&:name),
      response_types_supported: Client.available_response_types,
      grant_types_supported: Client.available_grant_types,
      
      # request object
      request_parameter_supported: true,
      request_uri_parameter_supported: true,
      request_object_signing_alg_values_supported: [:HS256, :HS384, :HS512], 
      
      subject_types_supported: ['public', 'pairwise'],
      id_token_signing_alg_values_supported: [:RS256],
      token_endpoint_auth_methods_supported: ['client_secret_basic', 'client_secret_post'],
      claims_supported: ['sub', 'iss',
                         'name', 'email', 'address', 'profile', 'locale', 'phone_number'], 
      # PKCE
      code_challenge_methods_supported: ['S256']
    )
    render json: config
  end
end

# -*- coding:utf-8 -*-

# 仕様に準拠していない点を通す修正.
#   issuer: https://www.paypal.com
#   configuration
#     https://www.paypal.com/.well-known/openid-configuration になるはずだが,
#     https://www.paypalobjects.com/.well-known/openid-configuration に301リダ
#     イレクトされる.
class OpenIDConnect::Discovery::Provider::Config
  # OpenID Connect Discovery 1.0 によれば、
  # OpenID Provider Configuration URI は、'issuer' にパスを付けることになって
  # いる
  def self.discover!(identifier, cache_options = {})
    if cache_options[:configuration_host_uri]
      # これは仕様違反
      uri = URI.parse(cache_options.delete :configuration_host_uri)
    else
      uri = URI.parse(identifier)
    end
    Resource.new(uri).discover!(cache_options).tap do |response|
      response.expected_issuer = identifier
      response.validate!
    end
  rescue SWD::Exception, ValidationFailed => e
    raise DiscoveryFailed.new(e.message)
  end
end


# omniauth-paypal パッケージはすでに廃れている。
# omniauth-paypal-oauth2 パッケージは, 開発が継続。

class PaypalConnector

  class << self
    def config
      return @config if @config
    
      @config = YAML.load_file(Rails.root.to_s + "/config/connect/paypal.yml")[Rails.env].symbolize_keys
      @config.merge! OpenIDConnect::Discovery::Provider::Config.discover!(
                     'https://www.paypal.com',
                     :configuration_host_uri => "https://www.paypalobjects.com"
                   ).as_json
      return @config
    end

    
    def client
      # OpenIDConnect::Client は Rack::OAuth2::Client の派生クラス
      @client ||= OpenIDConnect::Client.new(
        identifier:             config[:client_id],
        secret:                 config[:client_secret],
        authorization_endpoint: config[:authorization_endpoint],
        token_endpoint:         config[:token_endpoint],
        redirect_uri:           config[:redirect_uri]
      )
    end

    
    def authorization_uri(options = {})
      # テストのため、サポートされているもの全部。
      client.authorization_uri options.merge(
                        scope: (config[:scope] || config[:scopes_supported]),
                        #response_type: 'code id_token'
                             )
    end

    
    def authenticate code
      client.authorization_code = code

      # access_token!() は Rack::OAuth2::Client のメソッド.
      # この中で token_endpoint にアクセスする.
      # => access_token に加えて, id_token を得る, はず。
      # ここのドキュメントでも, id_token が得られる図になっている。
      # https://developer.paypal.com/docs/connect-with-paypal/integrate/#6-get-access-token

      # => しかし、実際には id_token は得られない。
      token = client.access_token! :basic # :client_secret_basic # :secret_in_body
      # これは使えない
      #id_token = OpenIDConnect::ResponseObject::IdToken.decode(
      #  token.id_token, :self_issued #, jwks
      #)

      # もう一度 API を叩く. もはや OpenID Connect ではない.
      http_client = Rack::OAuth2.http_client
      options = {:schema => 'paypalv1.1'}
      headers = {
        'Content-Type' => 'application/json',
        'Authorization' => 'Bearer ' + token.access_token
      }
      r = http_client.get(
            config[:userinfo_endpoint],
            options,
            headers)
      raise r.inspect  # DEBUG
      
      connect = find_or_initialize_by(identifier: id_token.subject)
      connect.access_token = token.access_token
      connect.id_token = id_token
      connect.save!
      connect.account || Account.create!(google: connect)
    end
  end # class << self
end


# PayPal に対して client (RP) として接続
class Connect::PaypalController < ApplicationController
  before_filter :require_anonymous_access
  
  # PayPal から戻ってくる
  # PayPal は 'GET' で戻してくる
  def show
    if params[:code].blank? || session[:state] != params[:state]
      raise AuthenticationRequired.new
    end
    authenticate PaypalConnector.authenticate(params[:code])
    logged_in!
  end

  
  # [POST] 認証開始 => PayPal にリダイレクト
  def create
    session[:state] = SecureRandom.hex(32)
    uri = PaypalConnector.authorization_uri(
      state: session[:state]
    )
    redirect_to uri
  end

end

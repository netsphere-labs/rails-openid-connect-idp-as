# -*- coding:utf-8 -*-

class Connect::Google < Connect::Base
  # 裏で YAML 形式で保存される。 -> 保存時にエラー.
  #serialize :id_token

  validates :identifier,   presence: true, uniqueness: true
  validates :access_token, presence: true, uniqueness: true


private

  def to_bearer_token
    Rack::OAuth2::AccessToken::Bearer.new(
      access_token: access_token
    )
  end

  def call_api(endpoint)
    # NOTE:
    # Google doesn't support Authorization header, so I put access_token in query for now.
    endpoint = URI.parse endpoint
    endpoint.query = {access_token: access_token}.to_query
    res = to_bearer_token.get(endpoint)
    case res.status
    when 200
      JSON.parse(res.body).with_indifferent_access
    when 401
      raise Authentication::AuthenticationRequired.new('Access Token Invalid or Expired')
    else
      raise Rack::OAuth2::Client::Error.new('API Access Faild')
    end
  end

  class << self
    def config
      return @config if @config
      
      # Ruby 3.1 で YAML (psych) 4.0.0 がバンドル。非互換.
      @config = YAML.load_file(Rails.root.to_s + "/config/connect/google.yml",
                               aliases: true)[Rails.env].symbolize_keys
      # discovery metadata のほうが優先
      @config.merge! OpenIDConnect::Discovery::Provider::Config.discover!(
                       @config[:issuer]
                     ).as_json
      if Rails.env.production?
        @config.merge!(
            client_id:     ENV['g_client_id'],
            client_secret: ENV['g_client_secret']
        )
      end
      return @config
    end


    def client
      @client ||= OpenIDConnect::Client.new(
        identifier:             config[:client_id],
        secret:                 config[:client_secret],
        authorization_endpoint: config[:authorization_endpoint],
        token_endpoint:         config[:token_endpoint],
        redirect_uri:           config[:redirect_uri]
      )
    end


    # @return Authentication Request URL
    def authorization_uri(options = {})
      # ここは `options` のほうが優先
      client.authorization_uri( {
                scope: config[:scopes_supported]
      }.merge(options) )
    end

    def jwks
      @jwks ||= JSON::JWK::Set.new(#JSON.parse(
        OpenIDConnect.http_client.get(config[:jwks_uri]).body # これは Hash
      )#)
    end

    # Sorcery -> user_class -> callback
    def authenticate(code, nonce)
      # token の検証
      client.authorization_code = code
      token = client.access_token! :secret_in_body  # ここで IdP にアクセス
      id_token = OpenIDConnect::ResponseObject::IdToken.decode(
        token.id_token, jwks
      )
      # 検証に失敗すると例外
      id_token.verify!({ :issuer => config[:issuer],
                         :nonce => nonce,
                         :client_id => config[:client_id] })

      ### id_token が得られた. ここからユーザ登録
      
      connect = find_or_initialize_by(identifier: id_token.subject)
      connect.access_token = token.access_token
      connect.id_token = id_token.as_json

      email = id_token.raw_attributes[:email]
      account = connect.account || Account.find_by_email(email) ||
                Account.new(email: email)
      Account.transaction do
        #account.google = connect  # Facebook が先にあった場合
        account.name = id_token.raw_attributes[:name]
        account.save!
        connect.account_id = account.id
        connect.save!
      end
      
      return account
    end
  end # class << self

end # class Connect::Google

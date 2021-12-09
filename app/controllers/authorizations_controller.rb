# -*- coding:utf-8 -*-

# OpenID Provider (OP) としての部分
# RFC 6749 (Oct 2012) The OAuth 2.0 Authorization Framework
# https://www.rfc-editor.org/rfc/rfc6749

class AuthorizationsController < ApplicationController
  rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
    @error = e
    logger.info e.backtrace[0,10].join("\n")
    render :error, status: e.status
  end

  # 認証の開始: 確認画面を表示
  # authorization_endpoint: "http://localhost:4000/authorizations/new"
  def new
    # viewstate に必要:
    #   @client, @response_type, @redirect_uri, @scopes,
    #   @_request_, @request_uri,
    #   @request_object
    call_authorization_endpoint false
  end

  # ユーザの approve/deny を受けて、RPにリダイレクトバックする.
  def create
    call_authorization_endpoint true, params[:approve]
  end


private

  def call_authorization_endpoint allow_approval, approved = false
    endpoint = authorization_endpoint_authenticator allow_approval, approved
    # [ 200, {"Content-Type" => "text/plain"}, ["Hello Rack!\n\n"] ]
    status, header, res_body = endpoint.call(request.env)
    
    require_login()  # 再ログインでここに戻ってくる. OK
    if !allow_approval
      if (max_age = @request_object.try(:id_token).try(:max_age)) &&
         current_user.last_login_at < max_age.seconds.ago
        flash[:alert] = 'Exceeded Max Age, Login Again'
        logout()
        require_login()
      end
    end

    # エラー時に、次のようにレスポンスヘッダに格納する
    #   HTTP/1.1 401 Unauthorized
    #   WWW-Authenticate: Bearer realm="example",
    #                     error="invalid_token",
    #                     error_description="The access token expired"
    # See RFC 6750 The OAuth 2.0 Authorization Framework: Bearer Token Usage
    ["WWW-Authenticate"].each do |key|
      response.headers[key] = header[key] if header[key].present?
    end
    case status
    when 302
      redirect_to header['Location']
    end
  end


  # @param allow_approval RPからのリダイレクトの時 false
  #                       ユーザによる approve/deny のとき true
  # @param approved       ユーザによる approve のとき true.
  #
  # @return [Rack::OAuth2::Server::Authorize] rackオブジェクト.
  def authorization_endpoint_authenticator allow_approval, approved = false
    return Rack::OAuth2::Server::Authorize.new do |req, res|
      raise TypeError if !req.is_a?(Rack::OAuth2::Server::Authorize::Request)
      raise TypeError if !res.is_a?(Rack::OAuth2::Server::Authorize::Response)

      @client = Client.find_by_identifier(req.client_id) || req.bad_request!
      res.redirect_uri = @redirect_uri = req.verify_redirect_uri!(@client.redirect_uris)
      if res.protocol_params_location == :fragment && req.nonce.blank?
        req.invalid_request! 'nonce required'
      end
      # req.scope は配列.
      openid_scope_value = false
      @scopes = req.scope.inject([]) do |_scopes_, scope|
                  openid_scope_value = true if scope == 'openid'
                  _scope_ = Scope.find_by_name(scope)
                  if _scope_
                    _scopes_ << _scope_
                  else
                    # ignore
                    # req.invalid_scope! "Unknown scope: #{scope}")
                  end
                  _scopes_
                end
      if !openid_scope_value
        req.invalid_request! '`openid` scope value required'
      end
      @request_object =
            if (@_request_ = req.request).present?
              OpenIDConnect::RequestObject.decode req.request, nil # @client.secret
            elsif (@request_uri = req.request_uri).present?
              OpenIDConnect::RequestObject.fetch req.request_uri, nil # @client.secret
            end

      # req.response_type = :code ... Symbol
      if Client.available_response_types.include?(
                    Array(req.response_type).collect(&:to_s).sort().join(' '))
        if allow_approval
          # ユーザによる approve/deny
          if approved
            approved! req, res
          else
            req.access_denied!
          end
        else
          # 当初リダイレクト時
          @response_type = req.response_type
        end
      else
        req.unsupported_response_type!
      end
    end
  end


  def approved!(req, res)
    # 'code',               # Authorization Code Flow
    # 'id_token token',     # Implicit Flow
    # 'code token',         # Hybrid Flow
    # 'code id_token',      # Hybrid Flow
    # 'code id_token token' # Hybrid Flow
    response_types = Array(req.response_type)
    fake_user = FakeUser.find params[:fake_user]

    if response_types.include? :code
      # Authentication Response では code (と state) しか返さない.
      # => この時点で, どのユーザか特定して保存が必要.
      authorization = Authorization.create!(
                                fake_user: fake_user,
                                client: @client,
                                redirect_uri: res.redirect_uri,
                                nonce: req.nonce)
      authorization.scopes << @scopes
      if @request_object
        authorization.create_authorization_request_object!(
          request_object: RequestObject.new(
            jwt_string: @request_object.to_jwt(@client.secret, :HS256)
          )
        )
      end
      res.code = authorization.code
    end

    # 事前検査済みなので、これでよい.
    if response_types.include? :token
      access_token = AccessToken.create!(fake_user:fake_user, client:@client)
      access_token.scopes << @scopes
      if @request_object
        access_token.create_access_token_request_object!(
          request_object: RequestObject.new(
            jwt_string: @request_object.to_jwt(@client.secret, :HS256)
          )
        )
      end
      res.access_token = access_token.to_bearer_token
    end

    if response_types.include? :id_token
      _id_token_ = IdToken.create!(fake_user:fake_user,
                                   client: @client,
                                   nonce: req.nonce )
      if @request_object
        _id_token_.create_id_token_request_object!(
          request_object: RequestObject.new(
            jwt_string: @request_object.to_jwt(@client.secret, :HS256)
          )
        )
      end
      res.id_token = _id_token_.to_jwt(
        code: (res.respond_to?(:code) ? res.code : nil),
        access_token: (res.respond_to?(:access_token) ? res.access_token : nil)
      )
    end
    res.approve!
  end

end # of class AuthorizationsController

# -*- coding:utf-8 -*-

# OpenID Provider (OP) としての部分
# RFC 6749 (Oct 2012) The OAuth 2.0 Authorization Framework
# https://www.rfc-editor.org/rfc/rfc6749

=begin
Sorcery: 明示的にログインした時刻

Activity Logging モジュールを使う.
 - `last_login_at`
 - `last_activity_at` などのフィールドをデータベースに保存.

Sorcery は, `Config.after_login` と `Config.after_remember_me` 設定がある。
前者は `login(*credentials)` 内から呼び出される。

Activity Logging の `last_login_at` は明示的にログインした時刻として使ってよい
=end


# 認可エンドポイント
class AuthorizationsController < ApplicationController
  rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
    @error = e
    logger.info e.backtrace[0,10].join("\n")
    render :error, layout:false, status: e.status
  end


  # GET
  # 認証の開始: 確認画面を表示
  # authorization_endpoint: "http://localhost:4000/authorizations/new"
  def new
    # まず, request object をつくる. 内部で client 検査
    @request_object = RequestObject.find_or_build_from_params params

    # 妥当性を確認する
    call_authorization_endpoint(@request_object) do |req, res|
      request_validation(req, res)
    end
    return if performed?  # エラー / リダイレクトの場合
      
    # ログインしていなければ、または max_age を経過していたら, ログインを求め
    # る. 
    # 本来は, 実際にログインするユーザ.
    if logged_in? && (max_age = @request_object.params['max_age']) &&
                     current_user.last_login_at < max_age.seconds.ago
      flash[:alert] = 'Exceeded Max Age, Login Again'
      logout() # ここでセッションがリセットされる
    end
    # かならず `logout()` より後ろに書く
    require_login()
    return if performed?  # 未ログイン: リダイレクトの場合
    
    # ここにはかならずログイン済みの状態
=begin
過去に認可を得ている scope であれば, そのまま RP にリダイレクトバックしてよい
  -> これは, アクセストークンの期限より長い。
     TODO: (FakeUser, Client, Scope) 表が必要
=end

    @viewstate = SecureRandom.alphanumeric(12)
    session[@viewstate] = {
      params: params  # 再現できるので、オリジナルのパラメータだけ.
    }
  end

  
  # POST
  # ユーザの approve/deny を受けて、RPにリダイレクトバックする.
  def create
    req = session[params['_viewstate']]['params'] # ここは key が文字列
    session.delete(params['_viewstate'])
    @request_object = RequestObject.find_or_build_from_params req

    @fake_user = FakeUser.find params[:fake_user]
    # {"openid"=>"1", "email"=>"1", "profile"=>"1"}
    @authorized_scopes = params[:scope].keys.map do |n|
      Scope.find_by_name(n) || raise
    end
    approved = params[:approve]
    
    call_authorization_endpoint(@request_object) do |req, res|
      # ユーザによる approve/deny
      if approved
        consent_and_redirect_back req, res
      else
        req.access_denied!
      end
    end
  end


private

  # だいぶ頭の痛い造りになっている
  # コールバックを強制させるつくりなのも厳しい。
  @@authorize_handlers = {
    # rack-oauth2
    'code' => Rack::OAuth2::Server::Authorize::Code ,
    'token' => Rack::OAuth2::Server::Authorize::Token, 
    'code token' => Rack::OAuth2::Server::Authorize::Extension::CodeAndToken ,
    # openid_connect
    'id_token' => Rack::OAuth2::Server::Authorize::Extension::IdToken ,
    'id_token token' => Rack::OAuth2::Server::Authorize::Extension::IdTokenAndToken ,
    'code id_token' => Rack::OAuth2::Server::Authorize::Extension::CodeAndIdToken ,
    'code id_token token' => Rack::OAuth2::Server::Authorize::Extension::CodeAndIdTokenAndToken ,
  }

  def call_authorization_endpoint(request_obj, &block)
    endpoint = Rack::OAuth2::Server::Authorize.new &block
    req = {
      Rack::RACK_REQUEST_QUERY_HASH => request_obj.params,
      Rack::RACK_REQUEST_QUERY_STRING => "X",
      Rack::QUERY_STRING => "X",
      Rack::RACK_INPUT => "X",
    }
    # 戻り値 = [ 200, {"Content-Type" => "text/plain"}, ["Hello Rack!\n\n"] ]
    status, header, res_body = endpoint.call(req)
    
    # エラー時に、次のようにレスポンスヘッダに格納する. Status は上のほうの
    # `rescue_from` で set される.
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


  # 当初リダイレクト時に callback
  # View で表示するため, 次を設定:
  #   @client, @redirect_uri, @scopes
  def request_validation req, res
    response_type = Array(req.response_type).collect(&:to_s).sort().join(' ')
    if !Client.available_response_types.include?(response_type)
      raise Rack::OAuth2::Server::Authorize::BadRequest.new("unsupported `response_type`")
    end
    
    @client = Client.find_by_identifier(req.client_id) || req.bad_request!
    @redirect_uri = req.verify_redirect_uri!(@client.redirect_uris)

    # req.scope は配列.
    @scopes = req.scope.inject([]) do |_scopes_, scope|
                  _scope_ = Scope.find_by_name(scope)
                  if _scope_
                    _scopes_ << _scope_
                  else
                    # ignore
                    # req.invalid_scope! "Unknown scope: #{scope}")
                  end
                  _scopes_
              end
    # implicit, hybrid: `nonce` 必須.
    # FAPI 1.0: `openid` scope を要求した場合は `nonce` 必須.
    if (res.protocol_params_location == :fragment || Scope.ary_find(@scopes, 'openid')) &&
       req.nonce.blank?
      req.invalid_request! "`nonce` required"
    end
    # FAPI 1.0: `openid` scope を要求しなかった場合, `state` 必須.
    if !Scope.ary_find(@scopes, 'openid')
      req.invalid_request! "`state` required" if req.state.blank?
    end

    # OIDC 3.1.2.1 If the `openid` scope value is not present, the behavior is entirely unspecified. エラーにしてしまう
    if !Scope.ary_find(@scopes, 'openid')
      req.invalid_request! '`openid` scope value required'
    end

    # PKCE
    if Array(req.response_type).include? :code
      if req.code_challenge_method != "S256"
        req.invalid_request!('only support `S256`') 
      end
    end
  end


  # 'code',               # Authorization Code Flow  認可コード
  # 'id_token token',     # Implicit Flow            IDトークン + アクセストークン #fragment. エラーも fragment で
  # 'code token',         # Hybrid Flow              認可コード + アクセストークン #fragment. エラーも fragment で
  # 'code id_token',      # Hybrid Flow              認可コード + IDトークン #fragment. エラーも fragment で.
  def consent_and_redirect_back(req, res)
    response_types = Array(req.response_type)
    res.redirect_uri = redirect_uri =
                req.verify_redirect_uri!(@request_object.client.redirect_uris)

    if response_types.include? :code
      # Authentication Response では code (と state) しか返さない.
      # => この時点で, どのユーザか特定して保存が必要.
      ActiveRecord::Base.transaction do
        authorization = Authorization.new(
                                fake_user: @fake_user,
                                client: @request_object.client,
                                redirect_uri: redirect_uri,
                                code_challenge: req.code_challenge, # PKCE
                                nonce: req.nonce)
        if req.claims && req.claims.length > 0
          @request_object.save!
          authorization.request_object_id = @request_object.id
        end
        authorization.save!
        authorization.scopes << @authorized_scopes # ユーザ (fake_user) が認可した scope
        
        res.code = authorization.code
      end
    end

    # 事前検査済みなので、これでよい.
    if response_types.include? :token
      ActiveRecord::Base.transaction do
        access_token = AccessToken.new(fake_user: @fake_user,
                                       client: @request_object.client)
        if req.claims && req.claims.length > 0
          if req.claims.userinfo 
            @request_object.save!
            access_token.request_object_id = @request_object.id
          end
        end
        access_token.save!
        access_token.scopes << @authorized_scopes

        res.access_token = access_token.to_bearer_token        
      end
    end

    if response_types.include? :id_token
      ActiveRecord::Base.transaction do
        _id_token_ = IdToken.new(fake_user: @fake_user,
                                 client: @request_object.client,
                                 nonce: req.nonce )
        if req.claims && req.claims.length > 0
          if req.claims.id_token
            @request_object.save!
            _id_token_.request_object_id = @request_object.id
          end
        end
        _id_token_.save!

        res.id_token = _id_token_.to_jwt(
          code: (res.respond_to?(:code) ? res.code : nil),
          access_token: (res.respond_to?(:access_token) ? res.access_token : nil)
        )
      end
    end
    
    res.approve!
  end

end # of class AuthorizationsController

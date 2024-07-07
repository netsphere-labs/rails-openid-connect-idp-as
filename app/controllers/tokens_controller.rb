# -*- coding:utf-8 -*-

# Token Endpoint
# The Authorization Code Flow: アクセストークンと id token の二つを返す.
class TokensController < ApiController
  #protect_from_forgery with: :null_session
  
  # POST /access_tokens
  def index
    status, header, res_body = token_endpoint().call(request.env)
    response.headers.merge!(header)
    # render text: は廃止.
    puts res_body.inspect
    render status: status, json: res_body.first
  end


private

  # Rack ミドルウェアを返す
  def token_endpoint
    return Rack::OAuth2::Server::Token.new do |req, res|
      client = Client.find_by_identifier(req.client_id) || req.invalid_client!
      client.secret == req.client_secret || req.invalid_client!
      case req.grant_type
      when :client_credentials
        res.access_token = client.access_tokens.create!.to_bearer_token
      when :authorization_code
        authorization = client.authorizations.where("code = ? and expires_at >= ?", req.code, Time.now.utc).take
        if !authorization || !authorization.valid_redirect_uri?(req.redirect_uri)
          req.invalid_grant!
        end
        # PKCE
        req.verify_code_verifier!(authorization.code_challenge)
        
        access_token = authorization.access_token
        res.access_token = access_token.to_bearer_token
        if access_token.accessible?(Scope::OPENID)
          res.id_token = access_token.fake_user.id_tokens.create!(
            client: access_token.client,
            nonce: authorization.nonce,
            request_object: authorization.request_object
          ).to_jwt
        end
      else
        req.unsupported_grant_type!
      end
    end
  end
  
end # class TokensController

module Rack
  module OAuth2
    class AccessToken
      class Bearer < AccessToken
        def token_response(options = {})
          response = super
          response[:token_type] = 'Bearer' # NOTE: ALB OIDC gateway currently cannot accept "bearer".
          Rails.logger.info(response)
          response
        end
      end
    end
  end
end


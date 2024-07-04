
# The UserInfo Endpoint MUST accept Access Tokens as OAuth 2.0 Bearer Token
# Usage [RFC6750].
class UserInfoController < ApiController
  # RFC 6750 Bearer Token Usage の方法でアクセストークンを受け入れる
  before_action :require_user_access_token

  #rescue_from FbGraph::Exception, Rack::OAuth2::Client::Error do |e|
  rescue_from Rack::OAuth2::Client::Error do |e|
    provider = case e
=begin                   
    when FbGraph::Exception
      'Facebook'
=end
    when Rack::OAuth2::Client::Error
      'Google'
    end
    raise Rack::OAuth2::Server::Resource::Bearer::BadRequest.new(
      :invalid_request, [
        "Your access token is valid, but we failed to fetch profile data from #{provider}.",
        "#{provider}'s access token on our side seems expired/revoked."
      ].join(' ')
    )
  end

  def show
    render json: @current_token.fake_user.to_response_object(@current_token)
  end

  
private

  def required_scopes
    Scope::OPENID
  end

  # for `before_action`
  def require_user_access_token
    require_access_token
    raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new(:invalid_token, 'User token is required') unless @current_token.fake_user
  end

  def require_access_token
    @current_token = request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
    unless @current_token
      raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new
    end
    unless @current_token.try(:accessible?, required_scopes)
      raise Rack::OAuth2::Server::Resource::Bearer::Forbidden.new(:insufficient_scope)
    end
  end
  
end

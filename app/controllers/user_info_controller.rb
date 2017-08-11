class UserInfoController < ApplicationController
  # See lib/authentication.rb
  before_filter :require_user_access_token

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
    render json: current_token.account.to_response_object(current_token)
  end

  private

  def required_scopes
    Scope::OPENID
  end
end

class ApplicationController < ActionController::Base
  include Authentication
  include Notification

  rescue_from HttpError do |e|
    render status: e.status, nothing: true
  end

  # Commented out Facebook by JB for this fork:
  # rescue_from FacebookOAuth::Exception, Rack::OAuth2::Client::Error do |e|
  #   redirect_to root_url, flash: {error: e.message}
  # end

  rescue_from Rack::OAuth2::Client::Error do |e|
    redirect_to root_url, flash: {error: e.message}
  end

  protect_from_forgery
end

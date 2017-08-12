class ApplicationController < ActionController::Base
  include Authentication
  include Notification

  rescue_from HttpError do |e|
    render status: e.status, nothing: true
  end
  
=begin
  # remove fb_graph

  rescue_from FbGraph::Exception, Rack::OAuth2::Client::Error do |e|
    redirect_to root_url, flash: {error: e.message}
  end
=end
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

end # class ApplicationController

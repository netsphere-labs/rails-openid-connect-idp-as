
class SessionController < ApplicationController
  before_action :require_login
  
  # DELETE /session
  def destroy
    logout()
    redirect_to root_url
  end
end


class DashboardController < ApplicationController
  before_action :require_login

  def show
    @account = current_user
    @clients = @account.clients
    print Connect::Facebook.all.inspect  # DEBUG
  end
end

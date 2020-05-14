class DashboardController < ApplicationController
  before_filter :require_authentication

  def show
    @account = current_account
    @clients = current_account.clients
    print Connect::Facebook.all.inspect  # DEBUG
  end
end

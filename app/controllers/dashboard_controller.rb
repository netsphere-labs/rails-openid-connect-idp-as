
class DashboardController < ApplicationController
  before_action :require_login

  def show
    @account = current_user
    @clients = @account.clients
  end
end

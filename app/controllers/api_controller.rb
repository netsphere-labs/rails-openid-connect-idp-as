
class ApiController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  # 認可。ポカ避けのため, 不要な場合は `skip_before_action` すること。
  #before_action :bearer_authorization

private
  # for `before_action`
  def bearer_authorization
  end
  
end


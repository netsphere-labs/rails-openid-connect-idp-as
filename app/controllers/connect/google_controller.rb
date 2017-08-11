# -*- coding:utf-8 -*-

# Google に対して client (RP) として接続
class Connect::GoogleController < ApplicationController
  before_filter :require_anonymous_access

  # googleから戻ってくる
  def show
    if params[:code].blank? || session[:state] != params[:state]
      raise AuthenticationRequired.new
    end
    authenticate Connect::Google.authenticate(params[:code])
    logged_in!
  end

  
  # 認証開始 => googleにリダイレクト
  def new
    session[:state] = SecureRandom.hex(32)
    redirect_to Connect::Google.authorization_uri(
      state: session[:state]
    )
  end
end

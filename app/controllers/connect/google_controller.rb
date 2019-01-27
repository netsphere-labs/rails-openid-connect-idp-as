# -*- coding:utf-8 -*-

# Google に対して client (RP) として接続
class Connect::GoogleController < ApplicationController
  before_filter :require_anonymous_access

  # googleから戻ってくる
  # Authorization Code Flow でも, GET method.
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
    session[:nonce] = SecureRandom.hex(32)
    redirect_to Connect::Google.authorization_uri(
      #response_type: 'id_token token', # Implicit Flow
      state: session[:state],
      #nonce: session[:nonce], # Implicit Flow では必須            
    )
  end
end

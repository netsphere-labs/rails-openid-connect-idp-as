# -*- coding:utf-8 -*-

# Google に対して client (RP) として接続
class Connect::GoogleController < ApplicationController

  # googleから戻ってくる
  # GET /connect/google or /connect/google.json
  # Authorization Code Flow でも, GET method.
  def show
    if params[:code].blank? || session[:state] != params[:state]
      raise AuthenticationRequired.new
    end

    # login() 内部で user_class.authenticate(*credentials) が呼び出される
    if login(Connect::Google, params[:code])  
      redirect_back_or_to('/dashboard', notice: 'Login successful')
    else
      flash[:alert] = 'Login failed'
      redirect_to '/'
    end
  end


  # [POST] 認証開始 => googleにリダイレクト
  # POST /connect/google or /connect/google.json
  def create
    session[:state] = SecureRandom.hex(32)
    session[:nonce] = SecureRandom.hex(32)
    redirect_to Connect::Google.authorization_uri(
                  response_type: 'code', # Authorization Code Flow
                  #response_type: 'id_token token', # Implicit Flow
                  scope: ['openid', "email", "profile"], # 'openid' 必須
                  state: session[:state], # 推奨
                  nonce: session[:nonce]  # 推奨. Implicit Flow では必須
                )
  end
end

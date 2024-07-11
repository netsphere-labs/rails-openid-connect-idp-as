# -*- coding:utf-8 -*-

class Connect::FacebookController < ApplicationController

  # Facebook から戻ってくる.
  # GET /connect/facebook
  def show
    if login(Connect::Facebook, cookies, nil)
      redirect_back_or_to('/dashboard', notice: 'Login successful')
    else
      flash[:alert] = 'Login failed'
      redirect_to '/'
    end      
  end

end


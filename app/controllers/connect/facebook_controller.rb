# -*- coding:utf-8 -*-

class Connect::FacebookController < ApplicationController

  # Facebook から戻ってくる.
  # GET /connect/facebooks/1 or /connect/facebooks/1.json
  def show
    if login(Connect::Facebook, cookies)
      redirect_back_or_to('/dashboard', notice: 'Login successful')
    else
      flash[:alert] = 'Login failed'
      redirect_to '/'
    end      
  end

end


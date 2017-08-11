# -*- coding:utf-8 -*-

# クライアント (RP) の管理
class ClientsController < ApplicationController
  before_filter :require_authentication

  def new
    @client = current_account.clients.new
    # redirect_uri は複数持てる.
    @redirect_uris = ['']
  end

  
  def create
    @client = current_account.clients.new(client_params.permit(:name))
    @redirect_uris = client_params.permit(redirect_uris: [])[:redirect_uris]
    
    @client.redirect_uris = @redirect_uris.select do |uri|
                              uri.to_s.strip != ''
                            end
    if @client.save
      redirect_to dashboard_url, flash: {
        notice: "Registered #{@client.name}"
      }
    else
      flash[:error] = @client.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    @client = current_account.clients.find(params[:id])
    @redirect_uris = @client.redirect_uris
  end

  
  def update
    @client = current_account.clients.find(params[:id])
    @redirect_uris = client_params.permit(redirect_uris: [])[:redirect_uris]

    @client.attributes = client_params.permit(:name)
    @client.redirect_uris = @redirect_uris.select do |uri|
                              uri.to_s.strip != ''
                            end
    if @client.save
      redirect_to dashboard_url, flash: {
        notice: "Updated #{@client.name}"
      }
    else
      flash[:error] = @client.errors.full_messages.to_sentence
      render :edit
    end
  end

  
  def destroy
    current_account.clients.find(params[:id]).destroy
    redirect_to dashboard_url
  end

  private ###################################################################
  
  # Never trust parameters from the scary internet, only allow the white
  # list through.
  def client_params
    params.fetch(:client, {})
  end

end

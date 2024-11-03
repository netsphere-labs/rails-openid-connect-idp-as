# -*- coding:utf-8 -*-

# クライアント (RP) の管理
class ClientsController < ApplicationController
  before_action :require_login

  before_action :set_client, only: %i[ show edit update destroy ]

  # GET /clients/1 or /clients/1.json
  def show
  end

  # GET /clients/new
  def new
    @client = Client.new
    # redirect_uri は複数持てる.
    @redirect_uris = []
  end


  # POST /clients or /clients.json
  def create
    @client = Client.new(client_params.permit(:name))
    @client.account_id = current_user.id
    @redirect_uris = client_params.permit(redirect_uris: [])[:redirect_uris]
    
    @client.redirect_uris = @redirect_uris.select do |uri|
                              uri.to_s.strip != ''
                            end
    if @client.save
      redirect_to dashboard_url, flash: {
                    notice: "Client #{@client.name} was successfully created." }
    else
      flash[:alert] = @client.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity 
    end
  end


  # GET /clients/1/edit
  def edit
    @redirect_uris = @client.redirect_uris
  end


  # PATCH/PUT /clients/1 or /clients/1.json
  def update
    @redirect_uris = client_params.permit(redirect_uris: [])[:redirect_uris]

    @client.attributes = client_params.permit(:name)
    @client.redirect_uris = @redirect_uris.select do |uri|
                              uri.to_s.strip != ''
                            end
    if @client.save
      redirect_to dashboard_url, flash: {
                    notice: "Client #{@client.name} was successfully updated." }
    else
      #flash[:alert] = @client.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end


  # DELETE /clients/1 or /clients/1.json
  def destroy
    @client.destroy
    redirect_to dashboard_url, flash: {
                  notice: "Client #{@client.name} was successfully destroyed." }
  end


private ###################################################################

  # Use callbacks to share common setup or constraints between actions.
  def set_client
    @client = current_user.clients.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def client_params
    params.fetch(:client, {})
  end

end

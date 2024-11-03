class ScopesController < ApplicationController
  before_action :set_scope, only: %i[ show edit update destroy ]

  # GET /scopes or /scopes.json
  def index
    @scopes = Scope.all
  end

  # GET /scopes/1 or /scopes/1.json
  def show
  end

  # GET /scopes/new
  def new
    @scope = Scope.new
  end

  # GET /scopes/1/edit
  def edit
  end

  # POST /scopes or /scopes.json
  def create
    @scope = Scope.new(scope_params)

    respond_to do |format|
      if @scope.save
        format.html { redirect_to scope_url(@scope), notice: "Scope was successfully created." }
        format.json { render :show, status: :created, location: @scope }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @scope.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scopes/1 or /scopes/1.json
  def update
    respond_to do |format|
      if @scope.update(scope_params)
        format.html { redirect_to scope_url(@scope), notice: "Scope was successfully updated." }
        format.json { render :show, status: :ok, location: @scope }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @scope.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scopes/1 or /scopes/1.json
  def destroy
    @scope.destroy!

    respond_to do |format|
      format.html { redirect_to scopes_url, notice: "Scope was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scope
      @scope = Scope.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def scope_params
      params.fetch(:scope, {})
    end
end

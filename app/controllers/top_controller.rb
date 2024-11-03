class TopController < ApplicationController

  def index
    if current_user
      redirect_to '/clients/'
    end
  end
end

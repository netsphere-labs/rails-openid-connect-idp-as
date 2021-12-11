# -*- coding:utf-8 -*-

class ApplicationController < ActionController::Base
  # Rails v5.2 で、記述しなくてもよくなった。Hakiri 警告への対策.
  protect_from_forgery with: :exception
  
end # class ApplicationController


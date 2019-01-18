# -*- coding:utf-8; mode:ruby -*-

source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.9'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Supporting Rails 3 and 4.
gem 'squeel'

# 'caches_constants' class method that will cache lookup data
# バグ修正が app/models/scope.rb にある
gem 'constant_cache', '0.0.2'

#gem 'html5_validators'
gem 'validate_url'
gem 'validate_email'

# This gem is deprecated. Use 'fb_graph2' gem instead.
#gem 'fb_graph'

gem 'rack-oauth2'

# depends on json, validate_email, validate_url, webfinger, ...
# バグ修正が config/initializers 以下にある
gem 'openid_connect', '1.1.5'

#gem 'public_suffix', '< 3.0'
#gem 'json-jwt', '<= 1.9.2'

group :development, :test do
  gem 'sqlite3'
  gem 'test-unit', '~> 3.0'
  # A concurrent (multi-process) HTTP 1.1 server.
  #gem 'puma'

  # Access an IRB console on exception pages or by using <%= console %> in
  # views
  # v3.3 から rails5
  gem 'web-console', '~> 3.2.1'
end

group :test do
  # A set of alternative runners for MiniTest.
  #gem 'turn', :require => false
end

group :production do
  # Rails v4.2 は pg v1.0.0 では動かない。非互換.
  gem 'pg', '~> 0.21'
  #gem 'rack-ssl', :require => 'rack/ssl'
end

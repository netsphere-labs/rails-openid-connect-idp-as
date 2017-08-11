# -*- coding:utf-8; mode:ruby -*-

source 'http://rubygems.org'

gem 'rails', '~>4.2.9'

gem 'jquery-rails'

# Supporting Rails 3 and 4.
gem 'squeel'

# 'caches_constants' class method that will cache lookup data
gem 'constant_cache'

#gem 'html5_validators'
gem 'validate_url'
gem 'validate_email'

# This gem is deprecated. Use 'fb_graph2' gem instead.
#gem 'fb_graph'

gem 'rack-oauth2'

# depends on json, validate_email, validate_url, webfinger, ...
gem 'openid_connect'

group :development, :test do
  gem 'sqlite3'
  gem 'test-unit', '~> 3.0'
  # A concurrent (multi-process) HTTP 1.1 server.
  #gem 'puma'

  # Access an IRB console on exception pages or by using <%= console %> in
  # views
  gem 'web-console', '~> 2.0'
end

group :test do
  # A set of alternative runners for MiniTest.
  #gem 'turn', :require => false
end

group :production do
  gem 'pg'
  gem 'rack-ssl', :require => 'rack/ssl'
end

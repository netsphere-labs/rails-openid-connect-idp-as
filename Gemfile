# -*- coding:utf-8; mode:ruby -*-

source 'https://rubygems.org'

# Downgrade (remove default flag):
#    gem environment
#      - INSTALLATION DIRECTORY: /usr/local/lib/ruby/gems/2.5.0
#    rm /usr/local/lib/ruby/gems/2.5.0/specifications/default/bundler-2.1.4.gemspec 
gem 'bundler', '~> 1.17'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.11'

# Use SCSS for stylesheets
# 'Ruby Sass' has reached EOL and should no longer be used.
#gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
# OSVDB-126747 fix.
gem 'uglifier', '>= 2.7.2'

# Use jquery as the JavaScript library
# CVE-2019-11358 fix.
gem 'jquery-rails', '>= 4.3.4'

# Squeel unlocks the power of Arel.
# Supporting Rails 3 and 4.
gem 'squeel'

# 'caches_constants' class method that will cache lookup data
# バグ修正が app/models/scope.rb にある
gem 'constant_cache', '0.0.2'

#gem 'html5_validators'
gem 'validate_url'
gem 'validate_email'

# Facebook.
# 2020年5月現在, 比較的最近までメンテナンスされているものは、次の2択:
#   - https://github.com/nov/fb_graph2
#   - https://github.com/arsduo/koala
gem 'fb_graph2'

gem 'rack-oauth2'

# depends on json, validate_email, validate_url, webfinger, ...
# バグ修正が config/initializers 以下にある
gem 'openid_connect', '~> 1.1.8'

#gem 'public_suffix', '< 3.0'
#gem 'json-jwt', '<= 1.9.2'

group :development, :test do
  # v1.4.0 未対応.
  gem 'sqlite3', '~> 1.3.13'
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

# -*- coding:utf-8; mode:ruby -*-

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>= 3.0.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.3', '>= 6.1.3.2'

# Use SCSS for stylesheets
# 'Ruby Sass' has reached EOL and should no longer be used.
#gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
# OSVDB-126747 fix.
#gem 'uglifier', '>= 2.7.2'

# Use jquery as the JavaScript library
# CVE-2019-11358 fix.
#gem 'jquery-rails', '>= 4.3.4'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# Squeel unlocks the power of Arel.
# Supporting Rails 3 and 4.  -> Not 5
#gem 'squeel'

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
gem 'openid_connect', '~> 1.2.0'

group :development, :test do
  gem 'sqlite3', '~> 1.4'
  #gem 'test-unit', '~> 3.0'
  # A concurrent (multi-process) HTTP 1.1 server.
  #gem 'puma'

  # Access an IRB console on exception pages or by using <%= console %> in
  # views
  # v3.3 から rails5
  gem 'web-console', '>= 4.1.0'
end

group :test do
  # A set of alternative runners for MiniTest.
  #gem 'turn', :require => false
end

group :production do
  # Rails v4.2 は pg v1.0.0 では動かない。非互換.
  gem 'pg', '~> 1.2'
  #gem 'rack-ssl', :require => 'rack/ssl'
end

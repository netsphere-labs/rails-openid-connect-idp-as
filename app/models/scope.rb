# -*- coding:utf-8 -*-

=begin
# constant_cache パッケージ v0.0.2
module ConstantCache::CacheMethods::ClassMethods
  def caches_constants(additional_options = {})
    cattr_accessor :cache_options

    self.cache_options = {:key => :name, :limit => ConstantCache::CHARACTER_LIMIT}.merge(additional_options)
        
    raise ConstantCache::InvalidLimitError, "Limit of #{self.cache_options[:limit]} is invalid" if self.cache_options[:limit] < 1        
    self.all.each {|model| model.set_instance_as_constant } # fixed.
  end
end
=end


class Scope < ApplicationRecord
  has_many :access_token_scopes
  has_many :access_tokens, through: :access_token_scopes
  has_many :authorization_scopes
  has_many :authorizations, through: :authorization_scopes

  validates :name, presence: true, uniqueness: true

  #include ConstantCache
  #caches_constants
end


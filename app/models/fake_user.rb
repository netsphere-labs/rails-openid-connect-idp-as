# -*- coding:utf-8 -*-

# 払い出されるユーザ
class FakeUser < ApplicationRecord
  # 認証
  has_many :authorizations

  has_many :access_tokens
  has_many :id_tokens

  before_validation :setup, on: :create
  validates :identifier, presence: true, uniqueness: true

  
  def to_response_object access_token
    userinfo = userinfo()
    unless access_token.accessible?(Scope::PROFILE)
      userinfo.all_attributes.each do |attribute|
        userinfo.send("#{attribute}=", nil) unless access_token.accessible?(attribute)
      end
    end
    # scope values を使って claims を制限する。OIDC Section 5.4
    userinfo.email        = nil unless access_token.accessible?(Scope::EMAIL)   || access_token.accessible?(:email)
    userinfo.address      = nil unless access_token.accessible?(Scope::ADDRESS) || access_token.accessible?(:address)
    userinfo.phone_number = nil unless access_token.accessible?(Scope::PHONE)   || access_token.accessible?(:phone)
    # `sub` は必須.
    userinfo.sub = if access_token.client.ppid?
                         ppid_for(access_token.client.sector_identifier).identifier
                   else
                     identifier
                   end
    return userinfo
  end


private

  def setup
    self.identifier = SecureRandom.hex(8)
  end

  # @return [OpenIDConnect::ResponseObject::UserInfo]
  def userinfo
    attrs = {
      #sub:      identifier, # 必須. Subject - Identifier for the End-User at the Issuer
      # `profile` scope
      name:    name,
      profile: profile,
      locale:  locale,
      # `email` scope
      email:   email,
      # `address` scope
      address: address,
      # `phone` scope
      phone_number: phone_number,
    }
    return OpenIDConnect::ResponseObject::UserInfo.new attrs
  end

end


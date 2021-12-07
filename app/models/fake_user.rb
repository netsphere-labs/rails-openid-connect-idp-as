# -*- coding:utf-8 -*-

# 払い出されるユーザ
class FakeUser < ApplicationRecord
  # 認証
  has_many :authorizations

  has_many :access_tokens
  has_many :id_tokens

  before_validation :setup, on: :create
  validates :identifier, presence: true, uniqueness: true

  # @return [OpenIDConnect::ResponseObject::UserInfo]
  def userinfo
    attrs = {
      id:      identifier,
      name:    name,
      email:   email,
      address: address,
      profile: profile,
      phone_number: phone_number,
    }
    return OpenIDConnect::ResponseObject::UserInfo.new attrs
  end
  
  def to_response_object access_token
    userinfo = userinfo()
    unless access_token.accessible?(Scope::PROFILE)
      userinfo.all_attributes.each do |attribute|
        userinfo.send("#{attribute}=", nil) unless access_token.accessible?(attribute)
      end
    end
    userinfo.email        = nil unless access_token.accessible?(Scope::EMAIL)   || access_token.accessible?(:email)
    userinfo.address      = nil unless access_token.accessible?(Scope::ADDRESS) || access_token.accessible?(:address)
    userinfo.phone_number = nil unless access_token.accessible?(Scope::PHONE)   || access_token.accessible?(:phone)
    userinfo.subject = if access_token.client.ppid?
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
end


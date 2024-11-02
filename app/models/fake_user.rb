# -*- coding:utf-8 -*-

# 払い出されるユーザ
class FakeUser < ApplicationRecord
  # 認証
  has_many :authorizations

  has_many :access_tokens
  has_many :id_tokens
  # PPID
  has_many :pairwise_pseudonymous_identifiers

  before_validation :setup, on: :create
  
  validates :identifier, presence: true, uniqueness: true
  validates :name,       presence: true
  validates :email,      presence: true, uniqueness: true

  
  def to_response_object access_token
    userinfo = userinfo()
    #raise userinfo.inspect  # この段階では email 入っている
    unless access_token.accessible?(Scope::PROFILE)
      userinfo.all_attributes.each do |attribute|
        userinfo.send("#{attribute}=", nil) unless access_token.accessible?(attribute)
      end
    end
    # scope values を使って claims を制限する。OIDC Section 5.4
    if !access_token.accessible?(Scope::EMAIL)
      userinfo.email = nil; userinfo.email_verified = nil
    else
      userinfo.email          = nil if !access_token.accessible?(:email)
      userinfo.email_verified = nil if !access_token.accessible?(:email_verified)
    end
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

  def ppid_for(sector_identifier)
    # OIDC Section 8.1. 計算方法が指定されている
    self.pairwise_pseudonymous_identifiers.find_or_create_by_sector_identifier! sector_identifier
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
      email_verified: email_verified,
      # `address` scope
      address: address,
      # `phone` scope
      phone_number: phone_number,
    }
    return OpenIDConnect::ResponseObject::UserInfo.new attrs
  end

end


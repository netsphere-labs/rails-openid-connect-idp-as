# -*- coding:utf-8 -*-

=begin
リクエストオブジェクトで, scope だけでなく, クレームも細かく要求できる。
"userinfo", "id_token" の二つ. OIDC Section 5.5
 {
   "iss": "s6BhdRkqt3",
   "aud": "https://server.example.com",
   "response_type": "code id_token",
   "client_id": "s6BhdRkqt3",
   "redirect_uri": "https://client.example.org/cb",
   "scope": "openid",
   "state": "af0ifjsldkj",
   "nonce": "n-0S6_WzA2Mj",
   "max_age": 86400,
   "claims": {
     "userinfo": {
       "given_name": {"essential": true},
       "nickname": null,
       "email": {"essential": true},
       "email_verified": {"essential": true},
       "picture": null
      },
     "id_token": {
       "gender": null,
       "birthdate": {"essential": true},
       "acr": {"values": ["urn:mace:incommon:iap:silver"]}
     }
   }
 }
=end

class AccessToken < ApplicationRecord
  # RP
  belongs_to :client
  # 払い出すユーザ
  belongs_to :fake_user
  
  has_many :access_token_scopes
  has_many :scopes, through: :access_token_scopes
  
  #has_one :access_token_request_object
  # "claims": "userinfo" クレーム要求を含めることができる。
  belongs_to :request_object, optional:true #, through: :access_token_request_object

  before_validation :setup, on: :create

  validates :token,      presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :valid, lambda {
    where { expires_at >= Time.now.utc }
  }

  def to_bearer_token
    Rack::OAuth2::AccessToken::Bearer.new(
      access_token: token,
      expires_in: (expires_at - Time.now.utc).to_i
    )
  end

  def accessible?(_scopes_or_claims_ = nil)
    claims = request_object.try(:to_request_object).try(:userinfo)
    Array(_scopes_or_claims_).all? do |_scope_or_claim_|
      case _scope_or_claim_
      when Scope
        scopes.include? _scope_or_claim_
      else
        claims.try(:accessible?, _scope_or_claim_)
      end
    end
  end


private

  def setup
    self.token      = SecureRandom.hex(32)
    self.expires_at = 24.hours.from_now
  end
end

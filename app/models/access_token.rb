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

  # scope が大括り, claim が個々の項目
  # @param _scope_ [Scope] ユーザがその scope の払出しを認めたか
  def accessible?( _scope_ )
    raise TypeError if !_scope_.is_a?(Scope)
    # リクエストされた claims. 意味が違う
    #claims = request_object ? request_object.params['claims'].try(:userinfo) : nil

    # scopes = ユーザが払出しを認めたスコープ.
    return scopes.include?(_scope_)
  end


private

  def setup
    self.token      = SecureRandom.hex(32)
    self.expires_at = 24.hours.from_now
  end
end

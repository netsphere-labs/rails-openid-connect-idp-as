# -*- coding:utf-8 -*-

# クライアント (RP) からの認証
class Authorization < ApplicationRecord
  # RP
  belongs_to :client
  # 払い出すユーザ
  belongs_to :fake_user

  # ユーザ (fake_user) が、クライアント (RP) に対して何の scope を認可したのか
  has_many :authorization_scopes
  has_many :scopes, through: :authorization_scopes
  
  #has_one :authorization_request_object
  # "claims" リクエストパラメータがあった場合, アクセストークン・id token の
  # レスポンスに含めるクレームを削る
  belongs_to :request_object, optional:true #through: :authorization_request_object

  before_validation :setup, on: :create

  validates :client,     presence: true
  validates :fake_user,  presence: true
  validates :code,       presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :valid, lambda {
    where { expires_at >= Time.now.utc }
  }

  def expire!
    self.expires_at = Time.now
    self.save!
  end

  def access_token
    @access_token ||= expire! && generate_access_token!
  end

  def valid_redirect_uri?(given_uri)
    given_uri == redirect_uri
  end


private

  def setup
    self.code       = SecureRandom.hex(32)
    self.expires_at = 5.minutes.from_now
  end

  def generate_access_token!
    token = AccessToken.create!(client: client, fake_user: fake_user)
    token.scopes << scopes
    token.request_object = request_object
    token
  end
end

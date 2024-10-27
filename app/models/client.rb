# -*- coding:utf-8 -*-

# Relying Party (RP)
class Client < ApplicationRecord
  [:contacts, :redirect_uris, :raw_registered_json].each do |serializable|
    # rails 7.2: 引数の数が変更. v7.1: 第2引数としてクラス名も可
    serialize serializable, coder: JSON
  end

  # 'admin' account が client を所有する. => テナントの位置づけ
  # IdP では, RP を登録する開発者とログインする一般ユーザは、まったく別。
  # Dynamic Client Registration 1.0 の場合, null になる.
  belongs_to :account, optional: true
  
  has_many :access_tokens
  has_many :authorizations

  before_validation :setup, on: :create

  validates :account,    presence: {unless: :dynamic?}
  validates :identifier, presence: true, uniqueness: true
  validates :secret,     presence: true
  validates :name,       presence: true

  validate :check_redirect_uris
  
  # 第2引数はλ式
  scope :dynamic, -> { where(dynamic: true) }
  scope :valid, -> {
    where {
      (expires_at == nil) ||
      (expires_at >= Time.now.utc)
    }
  }

  class << self
    def available_response_types
      ['code',               # Authorization Code Flow
       #'id_token',           # Implicit Flow
       'id_token token',     # Implicit Flow
       'code token',         # Hybrid Flow
       'code id_token',      # Hybrid Flow
       #'code id_token token' # Hybrid Flow
      ]
    end

    # クライアントが token endpoint で使う
    # "grant_types_supported": RFC 8414, the default is ["authorization_code", "implicit"]
    def available_grant_types
      ['authorization_code'
       #, 'implicit',  おそらく使われる機会がない. response_type=token (RFC7591)
       #'refresh_token'  ● TODO: サポート
      ] 
    end

    def register!(registrar)
      registrar.validate!
      client = dynamic.new
      client.attributes = {
        native:            registrar.application_type == 'native',
        ppid:              registrar.subject_type == 'pairwise',
        name:              registrar.client_name,
        jwks_uri:          registrar.jwks_uri,
        sector_identifier: registrar.sector_identifier,
        redirect_uris:     registrar.redirect_uris
      }.delete_if do |key, value|
        value.nil?
      end
      client.raw_registered_json = registrar.as_json
      client.save!
      client
    end
  end # class << self

  
=begin
  # for views/clients/_form.html.erb
  attr_accessor :redirect_uri
  def redirect_uri=(redirect_uri)
    self.redirect_uris = Array(redirect_uri)
  end
=end


  def as_json(options = {})
    hash = raw_registered_json || {}
    hash.merge!(
      client_id: identifier,
      expires_at: expires_at.to_i,
      registration_access_token: 'fake'
    )
    hash[:client_secret] = secret unless native?
    hash
  end


private

  # For `before_validation()`
  def setup
    self.identifier = SecureRandom.hex(16)
    self.secret     = SecureRandom.hex(32)
    self.expires_at = 1.hour.from_now if dynamic?
    self.name     ||= 'Unknown'
  end

  # for `validate()`
  def check_redirect_uris
    redirect_uris.each do |redirect_uri|
      begin
        uri = URI.parse(redirect_uri)
        if !(uri && ['https', 'http'].include?(uri.scheme) && !uri.host.blank?)
          errors.add :redirect_uris, 'invalid redirect_uri: ' + redirect_uri
        end
      rescue URI::InvalidURIError
        errors.add :redirect_uris, 'invalid URI: ' + redirect_uri
      end
    end
  end

end

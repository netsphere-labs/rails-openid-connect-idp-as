# -*- coding:utf-8 -*-

# テナント
class Account < ApplicationRecord
  # ユーザモデル・クラス名が User でない場合は, config/initializers/sorcery.rb
  # ファイル内のクラス名を書き換えること.
  authenticates_with_sorcery!

  has_one :facebook, class_name: 'Connect::Facebook', dependent: :destroy
  has_one :google,   class_name: 'Connect::Google', dependent: :destroy
  #has_one :fake,     class_name: 'Connect::Fake', dependent: :destroy

  # 'developer' account が client を所有する. (テナント扱い)
  # 通常, 開発者と一般ユーザで、アカウントをまったく分けたりはしない.
  has_many :clients
  
  has_many :access_tokens
  has_many :authorizations
  has_many :id_tokens
  has_many :pairwise_pseudonymous_identifiers

  before_validation :setup, on: :create

  validates :identifier, presence: true, uniqueness: true

  class << self
    # Sorcery login() から callback される.
    def authenticate provider_class, code
      yield provider_class.authenticate(code)
    end
  end # class << self


  def to_response_object(access_token)
    userinfo = (google || facebook || fake).userinfo
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
    userinfo
  end

  def ppid_for(sector_identifier)
    self.pairwise_pseudonymous_identifiers.find_or_create_by_sector_identifier! sector_identifier
  end

  private

  def setup
    self.identifier = SecureRandom.hex(8)
  end
end

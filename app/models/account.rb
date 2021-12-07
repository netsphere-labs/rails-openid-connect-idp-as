# -*- coding:utf-8 -*-

# テナント
class Account < ApplicationRecord
  # ユーザモデル・クラス名が User でない場合は, config/initializers/sorcery.rb
  # ファイル内のクラス名を書き換えること.
  authenticates_with_sorcery!

  has_one :facebook, class_name: 'Connect::Facebook', dependent: :destroy
  has_one :google,   class_name: 'Connect::Google', dependent: :destroy
  #has_one :fake,     class_name: 'Connect::Fake', dependent: :destroy

  # 'admin' account が client を所有する. (テナント扱い)
  # 通常, 開発者と一般ユーザで、アカウントをまったく分けたりはしない.
  has_many :clients
  
  #has_many :access_tokens
  #has_many :authorizations
  #has_many :id_tokens
  has_many :pairwise_pseudonymous_identifiers

  before_validation :setup, on: :create

  validates :identifier, presence: true, uniqueness: true

  class << self
    # Sorcery login() から callback される.
    def authenticate provider_class, code
      yield provider_class.authenticate(code)
    end
  end # class << self


  def ppid_for(sector_identifier)
    self.pairwise_pseudonymous_identifiers.find_or_create_by_sector_identifier! sector_identifier
  end


private

  def setup
    self.identifier = SecureRandom.hex(8)
  end
end

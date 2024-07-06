
# PPID (Pairwise Pseudonymous Identifier): 仮名識別子
# 連携先ごとに異なる識別子を割り当てる。`sub` で返す
class PairwisePseudonymousIdentifier < ApplicationRecord
  belongs_to :fake_user

  before_validation :setup, on: :create

  # Web アプリ, native app などで client id が異なる。
  # client id 間で異なる user id を返すのはやりすぎ。
  # `account` ごとに値を設定
  validates :sector_identifier, presence: true, uniqueness: {scope: :fake_user_id}
  
  validates :identifier,        presence: true, uniqueness: true

  private

  def setup
    self.identifier = SecureRandom.hex(16)
  end
end

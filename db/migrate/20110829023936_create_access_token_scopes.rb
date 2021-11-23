
# 中間テーブル
class CreateAccessTokenScopes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :access_token_scopes do |t|
      t.belongs_to :access_token, :scope
      t.timestamps
    end
  end

  def self.down
    drop_table :access_token_scopes
  end
end

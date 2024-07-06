
# 中間テーブル
# Access token に許可された scopes
class CreateAccessTokenScopes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :access_token_scopes do |t|
      t.references :access_token, type: :integer, null:false, foreign_key:true
      t.references :scope,        type: :integer, null:false, foreign_key:true
      
      t.timestamps
    end
    add_index :access_token_scopes, [:access_token_id, :scope_id], unique:true
  end

  def self.down
    drop_table :access_token_scopes
  end
end


# The Authorization Code Flow
class CreateAuthorizations < ActiveRecord::Migration[4.2]
  def self.up
    create_table :authorizations do |t|
      t.belongs_to :account, :client
      t.string :code, null:false
      t.string :nonce
      t.string :redirect_uri
      t.datetime :expires_at
      t.timestamps
    end
    add_index :authorizations, :code, unique: true
  end

  def self.down
    drop_table :authorizations
  end
end

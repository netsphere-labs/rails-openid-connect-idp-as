class CreateIdTokens < ActiveRecord::Migration[4.2]
  def self.up
    create_table :id_tokens do |t|
      t.belongs_to :account, :client
      t.string :nonce
      t.datetime :expires_at
      t.timestamps
    end
  end

  def self.down
    drop_table :id_tokens
  end
end

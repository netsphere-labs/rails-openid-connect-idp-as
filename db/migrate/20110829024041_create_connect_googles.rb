class CreateConnectGoogles < ActiveRecord::Migration
  def self.up
    create_table :connect_google do |t|
      t.references :account, null: false, foreign_key: true
      t.string :identifier, null: false
      t.string :access_token
      t.text :id_token
      t.timestamps
    end
    add_index :connect_google, :access_token, unique: true
    add_index :connect_google, :identifier,   unique: true
  end

  def self.down
    drop_table :connect_googles
  end
end

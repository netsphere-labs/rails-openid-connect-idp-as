class CreateConnectGoogles < ActiveRecord::Migration
  def self.up
    create_table :connect_google do |t|
      t.belongs_to :account, foreign_key: true
      t.string :identifier, null: false, unique: true
      t.string :access_token, unique: true
      t.text :id_token
      t.timestamps
    end
  end

  def self.down
    drop_table :connect_googles
  end
end

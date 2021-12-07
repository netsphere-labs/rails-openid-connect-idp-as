# -*- coding:utf-8 -*-

# Relying Party (RP) テーブル
class CreateClients < ActiveRecord::Migration[4.2]
  def self.up
    create_table :clients do |t|
      t.belongs_to :account
      t.string :name,        null:false
      t.string :identifier,  null:false
      t.string :secret,      null:false
      t.string(
        :jwks_uri,
        :sector_identifier,
        :redirect_uris  # 配列
      )
      t.boolean :dynamic, :native, :ppid, default: false
      t.datetime :expires_at
      t.text :raw_registered_json
      t.timestamps
    end
    add_index :clients, :identifier, unique: true
  end

  def self.down
    drop_table :clients
  end
end


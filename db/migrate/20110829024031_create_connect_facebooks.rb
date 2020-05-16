# -*- coding: utf-8 -*-

class CreateConnectFacebooks < ActiveRecord::Migration
  def self.up
    create_table :connect_facebook do |t|
      t.references :account,   null: false, foreign_key: true
      t.string :identifier, null: false
      t.string :access_token
      t.timestamps
    end
    add_index :connect_facebook, :access_token, unique: true
    add_index :connect_facebook, :identifier,   unique: true
  end

  def self.down
    drop_table :connect_facebooks
  end
end

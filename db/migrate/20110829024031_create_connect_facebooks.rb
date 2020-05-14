# -*- coding: utf-8 -*-

class CreateConnectFacebooks < ActiveRecord::Migration
  def self.up
    create_table :connect_facebook do |t|
      t.belongs_to :account, foreign_key: true
      t.string :identifier, null: false, unique: true
      t.string :access_token, unique: true
      t.timestamps
    end
  end

  def self.down
    drop_table :connect_facebooks
  end
end

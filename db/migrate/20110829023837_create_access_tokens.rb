# -*- coding:utf-8 -*-

class CreateAccessTokens < ActiveRecord::Migration[4.2]
  def self.up
    create_table :access_tokens do |t|
      # RP
      t.belongs_to :client,    null:false
      # 払い出されるユーザ
      #t.belongs_to :account
      t.belongs_to :fake_user, null:false

      t.string :token,         null:false # unique
      t.datetime :expires_at,  null:false
      t.timestamps
    end
    add_index :access_tokens, :token, unique: true
  end

  def self.down
    drop_table :access_tokens
  end
end

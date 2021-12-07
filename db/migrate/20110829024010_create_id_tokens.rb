# -*- coding:utf-8 -*-

class CreateIdTokens < ActiveRecord::Migration[4.2]
  def self.up
    create_table :id_tokens do |t|
      # 払い出すユーザ
      #t.belongs_to :account, null:false
      t.belongs_to :fake_user, null:false
      # RP
      t.belongs_to :client,  null:false

      t.string :nonce
      t.datetime :expires_at
      t.timestamps
    end
  end

  def self.down
    drop_table :id_tokens
  end
end

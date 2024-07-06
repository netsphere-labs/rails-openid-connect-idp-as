# -*- coding:utf-8 -*-

class CreateIdTokens < ActiveRecord::Migration[4.2]
  def self.up
    create_table :id_tokens do |t|
      # 払い出すユーザ
      t.references :fake_user, type: :integer, null:false, foreign_key: true
      # RP
      t.references :client,    type: :integer, null:false, foreign_key: true

      # FAPI で必須に.
      t.string :nonce, null:false

      # "exp" クレームに埋め込む (必須クレーム)
      t.datetime :expires_at, null:false
      
      # "claims": "id_token" クレーム要求
      t.references :request_object, type: :integer, foreign_key: true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :id_tokens
  end
end

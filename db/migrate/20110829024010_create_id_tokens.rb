# -*- coding:utf-8 -*-

class CreateIdTokens < ActiveRecord::Migration[4.2]
  def self.up
    create_table :id_tokens do |t|
      # 払い出すユーザ
      t.references :fake_user, type: :integer, null:false
      # RP
      t.references :client,    type: :integer, null:false

      # `nonce` を必須に。FAPI
      t.string :nonce, null:false

      # "exp" クレームで埋め込む (必須クレーム)
      t.datetime :expires_at, null:false
      
      # "claims" リクエストパラメータ
      t.references :request_object, type: :integer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :id_tokens
  end
end

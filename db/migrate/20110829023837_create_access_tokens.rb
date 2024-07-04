# -*- coding:utf-8 -*-

class CreateAccessTokens < ActiveRecord::Migration[4.2]
  def self.up
    create_table :access_tokens do |t|
      # RP
      t.references :client,    type: :integer, null:false
      # 払い出されるユーザ
      t.references :fake_user, type: :integer, null:false

      t.string :token,         null:false, index: {unique: true}
      t.datetime :expires_at,  null:false

      # "claims" リクエストパラメータ
      t.references :request_object, type: :integer

      t.timestamps
    end
  end

  def self.down
    drop_table :access_tokens
  end
end

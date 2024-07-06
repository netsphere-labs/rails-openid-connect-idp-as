# -*- coding:utf-8 -*-

# The Authorization Code Flow
class CreateAuthorizations < ActiveRecord::Migration[4.2]
  def self.up
    create_table :authorizations do |t|
      # RP
      t.references :client,    type: :integer, null:false, foreign_key: true
      # 払い出すユーザ
      t.references :fake_user, type: :integer, null:false, foreign_key: true

      t.string :code,          null:false, index: {unique: true}
      t.string :nonce
      t.string :redirect_uri
      t.datetime :expires_at,  null:false

      # "claims" リクエストパラメータ
      t.references :request_object, type: :integer, foreign_key: true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :authorizations
  end
end

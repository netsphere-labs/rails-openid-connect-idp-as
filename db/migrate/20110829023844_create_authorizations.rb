# -*- coding:utf-8 -*-

# The Authorization Code Flow
class CreateAuthorizations < ActiveRecord::Migration[4.2]
  def self.up
    create_table :authorizations do |t|
      # RP
      t.belongs_to :client,    null:false
      # 払い出すユーザ
      #t.belongs_to :account,  null:false
      t.belongs_to :fake_user, null:false

      t.string :code,          null:false
      t.string :nonce
      t.string :redirect_uri
      t.datetime :expires_at,  null:false
      t.timestamps
    end
    add_index :authorizations, :code, unique: true
  end

  def self.down
    drop_table :authorizations
  end
end

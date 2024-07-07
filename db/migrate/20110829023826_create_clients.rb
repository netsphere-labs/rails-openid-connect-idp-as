# -*- coding:utf-8 -*-

# Relying Party (RP) テーブル
class CreateClients < ActiveRecord::Migration[4.2]
  def self.up
    create_table :clients do |t|
      # 登録した開発者
      # Dynamic Client Registration 1.0 の場合, null になる.
      t.references :account, type: :integer, foreign_key:true
      
      t.string :name,        null:false
      
      # `client_id`
      t.string :identifier,  null:false, index:{unique:true}
      
      t.string :secret,      null:false
      
      t.string(
        :jwks_uri,
        :redirect_uris  # 配列
      )
      t.boolean :dynamic, :native, :ppid, default: false

      # PPID 用. Host component of a URL used by the RP's organization.
      # フィールドは `clients` につくるが, 値は `account` 内で同じにする
      # See https://oauth.jp/blog/2019/06/08/sign-in-with-apple-analysis/
      t.string :sector_identifier
      
      t.datetime :expires_at
      t.text :raw_registered_json

      # JAR, `private_key_jwt` で使う
      t.string :client_public_keys
      
      t.timestamps
    end
  end

  def self.down
    drop_table :clients
  end
end


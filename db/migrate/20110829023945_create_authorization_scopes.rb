# -*- coding:utf-8 -*-

# クライアントリクエストでユーザが認証したとき、何の scope について認可したのか
# Scope が増えたときは再度認可が必要.
class CreateAuthorizationScopes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :authorization_scopes do |t|
      t.references :authorization, type: :integer, null:false
      t.references :scope,         type: :integer, null:false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :authorization_scopes
  end
end

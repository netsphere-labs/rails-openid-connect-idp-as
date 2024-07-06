# -*- coding:utf-8 -*-

# テナント. ここに clients = Relying Party (RP) をぶら下げる.
class CreateAccounts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :accounts do |t|
      # Facebook と Google で共通の id
      #t.string :identifier,   null:false
      
      t.string :email, null:false, index:{unique:true}
      t.string :name,  null:false

      # Sorcery ActivityLogging を有効にする.
      t.datetime :last_login_at
      t.datetime :last_logout_at
      t.datetime :last_activity_at
      t.string   :last_login_from_ip_address
      
      t.timestamps   null:false
    end
  end

  def self.down
    drop_table :accounts
  end
end

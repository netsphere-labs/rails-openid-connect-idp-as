# -*- coding:utf-8 -*-

# テナント. ここに clients = Relying Party (RP) をぶら下げる.
class CreateAccounts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :accounts do |t|
      # Facebook と Google で共通の id
      #t.string :identifier,   null:false
      t.string :email, null:false
      t.string :name,  null:false

      # Sorcery ActivityLogging を有効にすること.
      #t.datetime :last_logged_in_at
      t.datetime :last_login_at
      t.datetime :last_logout_at
      t.datetime :last_activity_at
      t.string   :last_login_from_ip_address
      
      t.timestamps   null:false
    end
    #add_index :accounts, :identifier, unique: true
    add_index :accounts, :email, unique:true
  end

  def self.down
    drop_table :accounts
  end
end

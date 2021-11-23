# -*- coding:utf-8 -*-

# テナント. ここに clients = Relying Party (RP) をぶら下げる.
class CreateAccounts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :accounts do |t|
      t.string :identifier,   null:false
      t.datetime :last_logged_in_at
      t.timestamps   null:false
    end
    add_index :accounts, :identifier, unique: true
  end

  def self.down
    drop_table :accounts
  end
end

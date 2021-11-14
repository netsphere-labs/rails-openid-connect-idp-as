# -*- coding:utf-8 -*-

# 払い出されるユーザ.
class CreateFakeUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :fake_users do |t|
      t.string :name,  null:false
      t.string :email, null:false
      t.string :address
      t.string :profile
      t.string :locale
      t.string :phone_number
      t.boolean :verified, null:false
      t.timestamps
    end
    add_index :fake_users, :email, unique:true
  end
end


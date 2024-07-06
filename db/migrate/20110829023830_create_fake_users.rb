# -*- coding:utf-8 -*-

# 払い出されるユーザ.
class CreateFakeUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :fake_users do |t|
      t.string :identifier,   null:false, index:{unique:true}

      t.string :name,  null:false
      t.string :email, null:false, index:{unique:true}
      t.string :address
      t.string :profile
      t.string :locale
      t.string :phone_number
      t.boolean :email_verified, null:false
      
      t.timestamps
    end
  end
end


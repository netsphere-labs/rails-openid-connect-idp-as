# -*- coding:utf-8 -*-

class CreateConnectGoogles < ActiveRecord::Migration[4.2]
  def self.up
    # 単数形 -> config/initializers/inflections.rb で単複同形の宣言要.
    create_table :connect_google do |t|
      t.references :account, null: false, foreign_key: true
      t.string :identifier,   null:false, index: {unique: true}
      t.string :access_token, null:false, index: {unique: true}
      t.text :id_token
      t.timestamps
    end
  end

  def self.down
    drop_table :connect_google
  end
end

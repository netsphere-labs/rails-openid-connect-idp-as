class CreateScopes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :scopes do |t|
      t.string :name, null:false
      t.timestamps
    end
    add_index :scopes, :name, unique: true
  end

  def self.down
    drop_table :scopes
  end
end

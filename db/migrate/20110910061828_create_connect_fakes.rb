class CreateConnectFakes < ActiveRecord::Migration
  def self.up
    create_table :connect_fakes do |t|
      t.references :account,   null: false, foreign_key: true
      t.timestamps
    end
  end

  def self.down
    drop_table :connect_fakes
  end
end

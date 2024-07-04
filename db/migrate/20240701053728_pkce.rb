
class Pkce < ActiveRecord::Migration[6.1]
  def change
    change_table :authorizations do |t|
      t.string :code_challenge
    end
  end
end

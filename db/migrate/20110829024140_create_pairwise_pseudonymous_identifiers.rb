
# PPID (Pairwise Pseudonymous Identifier): 仮名識別子
# 連携先ごとに異なる識別子を割り当てる。`sub` で返す
class CreatePairwisePseudonymousIdentifiers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :pairwise_pseudonymous_identifiers do |t|
      t.references :fake_user, type: :integer, null:false, foreign_key: true

      # `sub` でこれを返す
      t.string :identifier, null:false, index:{unique:true}

      # Host component of a URL used by the Relying Party's organization that
      # is an input to the computation of pairwise Subject Identifiers for that
      # Relying Party.
      # `account` ごとに値を設定.
      t.string :sector_identifier, null:false
      
      t.timestamps
    end
    add_index :pairwise_pseudonymous_identifiers,
              [:fake_user_id, :sector_identifier], unique:true
  end

  def self.down
    drop_table :pairwise_pseudonymous_identifiers
  end
end

class CreateRelationships < ActiveRecord::Migration[6.0]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    # 検索などの際の高速化のためのインデックス
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    # 一意性のためのインデックス
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end

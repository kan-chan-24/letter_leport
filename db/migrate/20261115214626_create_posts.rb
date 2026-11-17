class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.references :timeline_period, null: false, foreign_key: true
      t.integer :physical_condition, null: false
      t.integer :daily_condition, null: false
      t.integer :fun_condition, null: false
      t.text :content

      t.timestamps
    end

    add_index :posts, [ :user_id, :timeline_period_id ], unique: true
  end
end

class CreateTimelinePeriods < ActiveRecord::Migration[8.1]
  def change
    create_table :timeline_periods do |t|
      t.references :group, null: false, foreign_key: true
      t.datetime :started_at, null: false
      t.datetime :ended_at, null: false

      t.timestamps
    end
    add_index :timeline_periods, [ :group_id, :started_at ]
  end
end

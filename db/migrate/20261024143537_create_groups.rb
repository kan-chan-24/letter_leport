class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.string :invite_token, null: false, index: { unique: true }
      t.integer :interval_unit, null: false, default: 1
      t.integer :interval_count, null: false, default: 1
      t.integer :notify_day_of_week, null: false, default: 1
      t.integer :notify_day_of_month, null: false, default: 1
      t.integer :notify_hour, null: false, default: 9
      t.datetime :next_notify_at, null: false

      t.timestamps
    end
  end
end

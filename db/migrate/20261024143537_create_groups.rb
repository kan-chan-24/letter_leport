class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :invite_token
      t.integer :interval_unit
      t.integer :interval_count
      t.integer :notify_day_of_week
      t.integer :notify_day_of_month
      t.integer :notify_hour
      t.datetime :next_notify_at

      t.timestamps
    end
  end
end

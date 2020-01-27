class CreateOpenTimes < ActiveRecord::Migration[6.0]
  def change
    create_table :open_times do |t|
      t.integer :wday
      t.string :start_time
      t.string :end_time
      t.integer :activity_id

      t.timestamps
    end
  end
end

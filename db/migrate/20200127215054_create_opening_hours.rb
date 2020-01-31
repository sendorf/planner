class CreateOpeningHours < ActiveRecord::Migration[6.0]
  def change
    create_table :opening_hours do |t|
      t.integer :wday
      t.string :start_time
      t.string :end_time
      t.integer :activity_id

      t.timestamps
    end
  end
end

class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :event_name
      t.string :location
      t.integer :capacity
      t.integer :host_id

      t.timestamps
    end
  end
end

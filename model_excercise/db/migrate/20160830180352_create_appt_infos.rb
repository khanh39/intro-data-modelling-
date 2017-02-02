class CreateApptInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :appt_infos do |t|
      t.integer :doctor_id
      t.integer :patient_id
      t.time :appt_time
      t.string :appt_location
      t.boolean :spouse_accompanying?

      t.timestamps
    end
  end
end

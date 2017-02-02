class Doctor < ApplicationRecord
  
  has_many :appt_infos
  has_many :patients, through: :appt_info
end

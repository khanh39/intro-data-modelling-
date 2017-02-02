class Patient < ApplicationRecord
  has_many :appt_infos
  has_many :doctors, through: :appt_infos
end

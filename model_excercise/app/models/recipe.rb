class Recipe < ApplicationRecord
  has_many :ingredientrecipes
  has_many :ingedients, through: :ingredientrecipes
end

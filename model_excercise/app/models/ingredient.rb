class Ingredient < ApplicationRecord
  has_many :ingredientrecipes
  has_many :ingredient, through: :ingredientrecipes
end

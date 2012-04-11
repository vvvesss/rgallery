class Category < ActiveRecord::Base
  has_many :galleries
  validates :title, presence: true
  validates :title, uniqueness: true
end

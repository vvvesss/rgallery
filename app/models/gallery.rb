class Gallery < ActiveRecord::Base
  validates :title, :description, :category, presence: true
  validates :title, uniqueness: true
  has_many :images
end

class Gallery < ActiveRecord::Base
  validates :title, :description, presence: true
  validates :title, uniqueness: true
  has_many :images
  belongs_to :categoy
end


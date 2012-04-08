class Image < ActiveRecord::Base
  belongs_to :gallery  
  validates_uniqueness_of :fname, :scope => [:gallery_id]
end

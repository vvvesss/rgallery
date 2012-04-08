class AddGalleryIdColumn < ActiveRecord::Migration
  def up
  	add_column :images,:gallery_id, :integer
  end

  def down
  	remove_column :images,:gallery_id
  end
end

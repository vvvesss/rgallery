class RemoveGalleryCategory < ActiveRecord::Migration
  def up
    remove_column :galleries, :category
  end

  def down
    add_column :galleries, :category, :string
  end
end

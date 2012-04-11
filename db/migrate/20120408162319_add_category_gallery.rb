class AddCategoryGallery < ActiveRecord::Migration
  def up
      add_column :galleries, :category_id, :integer
  end

  def down
      remove_column :galleries, :category_id
  end
end

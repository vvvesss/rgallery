class AddGthumbColumn < ActiveRecord::Migration
  def up
  	add_column :images,:gthumb, :boolean
  end

  def down
  	remove_column :images,:gthumb
  end
end

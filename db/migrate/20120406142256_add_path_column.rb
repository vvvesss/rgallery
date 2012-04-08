class AddPathColumn < ActiveRecord::Migration
  def up
  	add_column :images,:path, :string
  end

  def down
  	remove_column :images,:path
  end
end

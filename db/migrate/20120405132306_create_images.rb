class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :fname
      t.string :description
      t.integer :seentimes
      t.integer :filesize
      
      t.timestamps
    end
  end
end

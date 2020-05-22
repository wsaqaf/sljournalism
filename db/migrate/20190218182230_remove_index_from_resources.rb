class RemoveIndexFromResources < ActiveRecord::Migration[5.1]
  def change
    remove_column :resources, :url
    add_column :resources, :url, :string
    add_index :resources, :url
  end
end

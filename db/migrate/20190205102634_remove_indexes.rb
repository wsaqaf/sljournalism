class RemoveIndexes < ActiveRecord::Migration[5.1]
  def change
    remove_index :media, :name
    add_index :media, :name
    remove_index :media, :url
    add_index :media, :url
    remove_index :srcs, :name
    add_index :srcs, :name
    remove_index :srcs, :url
    add_index :srcs, :url
  end
end

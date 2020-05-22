class MakeColumnsUniqueAndIndexedInClaimsMediaSources < ActiveRecord::Migration[5.1]
  def change
    add_index :claims, :title, unique: true
    add_index :claims, :url, unique: true
    add_index :media, :name, unique: true
    add_index :media, :url, unique: true
    add_index :srcs, :name, unique: true
    add_index :srcs, :url, unique: true
    add_index :resources, :name, unique: true
    add_index :resources, :url, unique: true
  end
end

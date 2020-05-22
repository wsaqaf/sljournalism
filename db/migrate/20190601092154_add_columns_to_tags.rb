class AddColumnsToTags < ActiveRecord::Migration[5.1]
  def change
    remove_index "name", name: "index_tags_on_name"
    add_column :tags, :claim_name, :string
    add_index :tags, :claim_name, :unique => true
    add_column :tags, :medium_name, :string
    add_index :tags, :medium_name, :unique => true
    add_column :tags, :src_name, :string
    add_index :tags, :src_name, :unique => true
    add_column :tags, :resource_name, :string
    add_index :tags, :resource_name, :unique => true
  end
end

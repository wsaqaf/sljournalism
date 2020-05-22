class RemoveIndexColumnsToTaggings < ActiveRecord::Migration[5.1]
  def change
    remove_column :taggings, :claim_id
    add_column :taggings, :claim_id, :integer
    remove_column :taggings, :medium_id
    add_column :taggings, :medium_id, :integer
    remove_column :taggings, :src_id
    add_column :taggings, :src_id, :integer
    remove_column :taggings, :resource_id
    add_column :taggings, :resource_id, :integer
    remove_column :taggings, :tag_id
    add_column :taggings, :tag_id, :integer
    add_index "taggings", ["claim_id"], name: "index_tags_on_claim_id", using: :btree
    add_index "taggings", ["medium_id"], name: "index_tags_on_medium_id", using: :btree
    add_index "taggings", ["src_id"], name: "index_tags_on_src_id", using: :btree
    add_index "taggings", ["resource_id"], name: "index_tags_on_resource_id", using: :btree
    add_index "taggings", ["tag_id"], name: "index_tags_on_tag_id", using: :btree
  end
end

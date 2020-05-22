class RemoveColumnsToTaggings < ActiveRecord::Migration[5.1]
  def change
    remove_column :taggings, :taggable_type
    remove_column :taggings, :tagger_id
    remove_column :taggings, :tagger_type
    remove_column :taggings, :context
    add_index :taggings, :claim_id, using: :btree
    add_index :taggings, :medium_id, using: :btree
    add_index :taggings, :src_id, using: :btree
    add_index :taggings, :resource_id, using: :btree
  end
end

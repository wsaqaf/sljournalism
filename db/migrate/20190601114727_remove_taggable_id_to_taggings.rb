class RemoveTaggableIdToTaggings < ActiveRecord::Migration[5.1]
  def change
    remove_index "taggable_id", name: "taggings_idx"
    remove_column :taggings, :taggable_id
  end
end

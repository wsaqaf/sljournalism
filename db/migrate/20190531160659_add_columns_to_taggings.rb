class AddColumnsToTaggings < ActiveRecord::Migration[5.1]
  def change
    add_column :taggings, :claim_id, :integer
    add_column :taggings, :medium_id, :integer
    add_column :taggings, :src_id, :integer
    add_column :taggings, :resource_id, :integer
  end
end

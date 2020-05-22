class RemoveCreatedAtToTaggings < ActiveRecord::Migration[5.1]
  def change
    remove_column :taggings, :created_at
    add_column :taggings, :created_at, :datetime
    change_column :taggings, :created_at, :datetime, :null => false
    add_column :taggings, :updated_at, :datetime
    change_column :taggings, :updated_at, :datetime, :null => false
  end
end

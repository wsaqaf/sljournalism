class UpdateColumnsToTags < ActiveRecord::Migration[5.1]
  def change
    remove_column :tags, :taggings_count
    add_column :tags, :created_at, :datetime
    change_column :tags, :created_at, :datetime, :null => false
    add_column :tags, :updated_at, :datetime
    change_column :tags, :updated_at, :datetime, :null => false
  end
end

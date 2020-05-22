class RemoveColumnNameToTags < ActiveRecord::Migration[5.1]
  def change
    remove_column :tags, :name
  end
end

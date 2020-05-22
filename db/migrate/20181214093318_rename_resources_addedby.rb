class RenameResourcesAddedby < ActiveRecord::Migration[5.1]
  def change
    rename_column :resources, :added_by, :user_id
  end
end

class RenameTypeToCategoryInClaims < ActiveRecord::Migration[5.1]
  def change
    rename_column :claims, :type, :category
  end
end

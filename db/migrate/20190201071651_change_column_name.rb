class ChangeColumnName < ActiveRecord::Migration[5.1]
  def change
    rename_column :claims, :category, :type
  end
end

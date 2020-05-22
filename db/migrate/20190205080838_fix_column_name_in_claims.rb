class FixColumnNameInClaims < ActiveRecord::Migration[5.1]
  def change
    rename_column :claims, :type, :has_image
  end
end

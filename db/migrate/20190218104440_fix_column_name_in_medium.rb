class FixColumnNameInMedium < ActiveRecord::Migration[5.1]
  def change
    rename_column :media, :type, :medium_type
  end
end

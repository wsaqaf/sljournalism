class RenameDetailsToDescriptionInClaimsAndSrcs < ActiveRecord::Migration[5.1]
  def change
    rename_column :media, :details, :description
    rename_column :srcs, :details, :description
  end
end

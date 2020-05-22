class RenameSourceIdToSrcIdColumnInClaims < ActiveRecord::Migration[5.1]
  def change
    rename_column :claims, :source_id, :src_id
  end
end

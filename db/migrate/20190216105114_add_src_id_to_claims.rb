class AddSrcIdToClaims < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :src_id, :integer
  end
end

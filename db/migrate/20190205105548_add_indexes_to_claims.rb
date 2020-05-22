class AddIndexesToClaims < ActiveRecord::Migration[5.1]
  def change
    add_index :claims, :medium_id
    add_index :claims, :src_id
  end
end

class RemoveIndexesClaims < ActiveRecord::Migration[5.1]
  def change
    remove_index :claims, :title
    add_index :claims, :title
    remove_index :claims, :url
    add_index :claims, :url
  end
end

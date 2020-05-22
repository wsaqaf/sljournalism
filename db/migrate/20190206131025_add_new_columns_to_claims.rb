class AddNewColumnsToClaims < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :medium_known, :integer
    add_column :claims, :medium_review_started, :integer
    add_column :claims, :src_known, :integer
    add_column :claims, :src_review_started, :integer
    add_column :claims, :img_review_started, :integer
    add_column :claims, :vid_review_started, :integer
  end
end

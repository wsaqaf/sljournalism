class RemoveIndexFromSrcandMedium < ActiveRecord::Migration[5.1]
  def change
    remove_column :medium_reviews, :medium_id
    remove_column :src_reviews, :src_id
    add_column :medium_reviews, :medium_id, :integer
    add_column :src_reviews, :src_id, :integer
    add_index :medium_reviews, :medium_id
    add_index :src_reviews, :src_id
  end
end

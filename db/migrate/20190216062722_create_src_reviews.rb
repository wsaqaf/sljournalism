class CreateSrcReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :src_reviews do |t|
      t.string :src_id
      t.string :name
      t.text :url
      t.text :description

      t.timestamps
    end
  end
end

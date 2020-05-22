class CreateClaimReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :claim_reviews do |t|
      t.string :src_id
      t.string :title
      t.text :url
      t.text :description

      t.timestamps
    end
  end
end

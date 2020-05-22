class CreateMediumReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :medium_reviews do |t|
      t.string :medium_id
      t.string :name
      t.text :url
      t.text :description

      t.timestamps
    end
  end
end

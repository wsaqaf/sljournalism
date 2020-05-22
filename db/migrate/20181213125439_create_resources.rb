class CreateResources < ActiveRecord::Migration[5.1]
  def change
    create_table :resources do |t|
      t.string :name
      t.text :description
      t.text :url
      t.text :tutorial
      t.text :icon
      t.integer :added_by
      t.timestamp :created_at

      t.timestamps
    end
  end
end

class CreateClaimSources < ActiveRecord::Migration[5.1]
  def change
    create_table :claim_sources do |t|
      t.string :name
      t.text :url
      t.text :details

      t.timestamps
    end
  end
end

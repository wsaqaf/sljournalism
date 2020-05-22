class CreateClaims < ActiveRecord::Migration[5.1]
  def change
    create_table :claims do |t|
      t.integer :claimid
      t.integer :claimtype
      t.string :claimtitle
      t.string :claimurl
      t.integer :claimsource
      t.integer :claimmedia
      t.text :claimdescription

      t.timestamps
    end
  end
end

class AddFieldsToClaims < ActiveRecord::Migration[5.2]
  def change
    add_column :claims, :add_to_blockchain, :integer
    add_column :claims, :expiry_date, :datetime
    add_column :claims, :bounty_amount, :integer
    add_column :claims, :conditions, :string
  end
end

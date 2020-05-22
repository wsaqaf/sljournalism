class AddSharingModeToClaims < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :sharing_mode, :integer
  end
end

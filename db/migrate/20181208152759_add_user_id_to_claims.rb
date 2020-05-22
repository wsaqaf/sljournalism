class AddUserIdToClaims < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :user_id, :integer
  end
end

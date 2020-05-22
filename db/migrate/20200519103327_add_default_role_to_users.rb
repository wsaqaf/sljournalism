class AddDefaultRoleToUsers < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :role, :string, :default => 'user'
  end
end

class AddGrpToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :grp, :string
  end
end

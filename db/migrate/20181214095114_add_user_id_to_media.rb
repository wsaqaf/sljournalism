class AddUserIdToMedia < ActiveRecord::Migration[5.1]
  def change
    add_column :media, :user_id, :integer
  end
end

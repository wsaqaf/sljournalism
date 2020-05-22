class AddUserIdToSrcs < ActiveRecord::Migration[5.1]
  def change
    add_column :srcs, :user_id, :integer
  end
end

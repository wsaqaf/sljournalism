class AddSharingModeToSrcs < ActiveRecord::Migration[5.1]
  def change
    add_column :srcs, :sharing_mode, :integer
  end
end

class AddSharingModeToMedia < ActiveRecord::Migration[5.1]
  def change
    add_column :media, :sharing_mode, :integer
  end
end

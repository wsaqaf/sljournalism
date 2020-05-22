class DropTools < ActiveRecord::Migration[5.1]
  def change
    drop_table :tools
  end
end

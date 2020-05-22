class AddIndexToSrcs < ActiveRecord::Migration[5.1]
  def change
    remove_column :srcs, :name
    add_column :srcs, :name, :string
    add_index :srcs, :name, unique: true
  end
end

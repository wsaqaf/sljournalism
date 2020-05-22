class AddIndexToMedia < ActiveRecord::Migration[5.1]
  def change
    remove_column :media, :name
    add_column :media, :name, :string
    add_index :media, :name, unique: true
  end
end

class ChangeTypeInSrcs < ActiveRecord::Migration[5.1]
  def change
    rename_column :srcs, :type, :src_type
  end
end

class ChangeClaimmediaToBeIntIntegerClaims < ActiveRecord::Migration[5.1]
  def change
    change_column :claims, :claimmedia, :integer
  end
end

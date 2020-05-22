class ChangeClaimmediaToBeStringInClaims < ActiveRecord::Migration[5.1]
  def change
    change_column :claims, :claimmedia, :string
  end
end

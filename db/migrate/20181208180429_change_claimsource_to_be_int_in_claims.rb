class ChangeClaimsourceToBeIntInClaims < ActiveRecord::Migration[5.1]
  def change
    change_column :claims, :claimsource, :integer
  end
end

class ChangeClaimsourceToBeStringInClaims < ActiveRecord::Migration[5.1]
  def change
    change_column :claims, :claimsource, :string
  end
end

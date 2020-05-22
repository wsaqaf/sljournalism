class AddHasTextToClaims < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :has_text, :integer
  end
end

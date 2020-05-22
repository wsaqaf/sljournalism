class AddHasVideoToClaims < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :has_video, :integer
  end
end

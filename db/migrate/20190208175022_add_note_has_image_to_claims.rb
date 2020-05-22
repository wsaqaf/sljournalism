class AddNoteHasImageToClaims < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :note_has_image, :string
  end
end

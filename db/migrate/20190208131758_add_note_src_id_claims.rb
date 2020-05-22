class AddNoteSrcIdClaims < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :note_src_id, :string
  end
end

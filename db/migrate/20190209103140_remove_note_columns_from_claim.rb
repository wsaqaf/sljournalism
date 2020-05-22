class RemoveNoteColumnsFromClaim < ActiveRecord::Migration[5.1]
  def change
    remove_column :claims, :note_img_review_started
    remove_column :claims, :note_vid_review_started
  end
end

class RenameAddedByToUserIdInQuestions < ActiveRecord::Migration[5.1]
  def change
    rename_column :questions, :added_by, :user_id    
  end
end

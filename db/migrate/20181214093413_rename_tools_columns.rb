class RenameToolsColumns < ActiveRecord::Migration[5.1]
  def change
    rename_column :answers, :q_id, :question_id
    rename_column :answers, :u_id, :user_id
  end
end

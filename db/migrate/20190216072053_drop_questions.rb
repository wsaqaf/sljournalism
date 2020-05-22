class DropQuestions < ActiveRecord::Migration[5.1]
  def change
    drop_table :questions
  end
end

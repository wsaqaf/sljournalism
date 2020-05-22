class AddCategoryToQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :questions, :category, :string
  end
end

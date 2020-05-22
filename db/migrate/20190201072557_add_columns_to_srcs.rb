class AddColumnsToSrcs < ActiveRecord::Migration[5.1]
  def change
    add_column :srcs, :type, :tinyint
    add_column :srcs, :lacks_proper_credentials, :tinyint
    add_column :srcs, :failed_factcheck_before, :tinyint
    add_column :srcs, :has_poor_writing_history, :tinyint
    add_column :srcs, :supported_by_trolls, :tinyint
    add_column :srcs, :difficult_to_locate, :tinyint
    add_column :srcs, :other_problems, :tinyint
    add_column :srcs, :review_verdict, :tinyint
    add_column :srcs, :review_description, :text
    add_column :srcs, :review_sharing_mode, :tinyint
    add_column :srcs, :review_is_completed, :boolean
  end
end

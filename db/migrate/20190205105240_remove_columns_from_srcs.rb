class RemoveColumnsFromSrcs < ActiveRecord::Migration[5.1]
  def change
    remove_column :srcs, :lacks_proper_credentials
    remove_column :srcs, :failed_factcheck_before
    remove_column :srcs, :has_poor_writing_history
    remove_column :srcs, :supported_by_trolls
    remove_column :srcs, :difficult_to_locate
    remove_column :srcs, :other_problems
    remove_column :srcs, :review_verdict
    remove_column :srcs, :review_description
    remove_column :srcs, :review_sharing_mode
    remove_column :srcs, :review_is_completed
  end
end

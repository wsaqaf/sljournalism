class AddForeignKeys < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :taggings, :claims
    add_foreign_key :taggings, :media
    add_foreign_key :taggings, :srcs
    add_foreign_key :taggings, :resources
    add_foreign_key :taggings, :tags
  end
end

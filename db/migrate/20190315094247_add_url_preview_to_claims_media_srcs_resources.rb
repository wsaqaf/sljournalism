class AddUrlPreviewToClaimsMediaSrcsResources < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :url_preview, :text
    add_column :media, :url_preview, :text
    add_column :srcs, :url_preview, :text
    add_column :resources, :url_preview, :text
  end
end

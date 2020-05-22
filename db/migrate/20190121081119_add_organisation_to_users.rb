class AddOrganisationToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :organisation, :string
  end
end

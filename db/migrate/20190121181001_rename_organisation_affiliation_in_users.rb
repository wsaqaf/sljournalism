class RenameOrganisationAffiliationInUsers < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :organisation, :affiliation
  end
end

class AddAuthorizedImportJobIdsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authorized_import_job_ids, :text
  end
end

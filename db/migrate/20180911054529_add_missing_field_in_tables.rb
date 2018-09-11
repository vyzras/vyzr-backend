class AddMissingFieldInTables < ActiveRecord::Migration[5.1]
  def change
    add_column :lists , :user_id , :integer
    add_column :lists , :guid,     :string
    add_column :items , :list_id , :integer
  end
end

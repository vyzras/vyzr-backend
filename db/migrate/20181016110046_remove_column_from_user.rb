class RemoveColumnFromUser < ActiveRecord::Migration[5.1]
  def change
    remove_column :users , :password, :string
    remove_column :users , :server_url, :string
    remove_column :users , :first_name, :string
    remove_column :users , :last_name, :string
    remove_column :users , :api_key, :string
    remove_column :users , :list_name, :string
    remove_column :users , :email, :string
  end
end

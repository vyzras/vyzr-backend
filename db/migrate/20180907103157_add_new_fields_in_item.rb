class AddNewFieldsInItem < ActiveRecord::Migration[5.1]
  def change
    add_column :items , :anonymous , :string
    add_column :items , :user_name , :string
  end
end

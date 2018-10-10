class AddSomeFields < ActiveRecord::Migration[5.1]
  def change
    add_column :items ,:created_time , :string
    add_column :items ,:updated_time , :string
  end
end

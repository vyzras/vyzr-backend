class AddItemId < ActiveRecord::Migration[5.1]
  def change
    add_column  :items , :item_id , :string
  end
end

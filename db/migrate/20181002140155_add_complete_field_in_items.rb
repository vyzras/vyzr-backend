class AddCompleteFieldInItems < ActiveRecord::Migration[5.1]
  def change
    add_column :items ,:complete_percentage ,:string
  end
end

class AddLastUpdatedInList < ActiveRecord::Migration[5.1]
  def change
    add_column :lists ,:last_updated , :string
  end
end

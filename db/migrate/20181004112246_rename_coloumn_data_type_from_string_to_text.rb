class RenameColoumnDataTypeFromStringToText < ActiveRecord::Migration[5.1]
  def change
    change_column :items ,:description  , :text, limit: 4.megabytes - 1
  end
end

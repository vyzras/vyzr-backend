class AddSyncInUser < ActiveRecord::Migration[5.1]
  def change
    add_column  :users , :is_sync, :bool ,default: false
  end
end

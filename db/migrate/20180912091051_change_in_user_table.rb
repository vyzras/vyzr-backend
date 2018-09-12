class ChangeInUserTable < ActiveRecord::Migration[5.1]
  def change
    add_column :users ,:subscribed , :boolean,  default: 0
  end
end

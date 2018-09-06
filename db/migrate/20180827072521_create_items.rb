class CreateItems < ActiveRecord::Migration[5.1]
  def change
    create_table :items do |t|
      t.string :title
      t.string :description
      t.string :image_url
      t.string :status
      t.string :author_id
      t.string :editor_id
      t.string :item_uri
      t.references :user
      t.timestamps
    end
  end
end

class AddAttachmentUrl < ActiveRecord::Migration[5.1]
  def change
    add_column :items ,:attachment_url , :string
  end
end

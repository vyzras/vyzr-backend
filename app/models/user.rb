class User < ApplicationRecord


  ####### Associations #########
  has_many :user_tokens
  has_one  :list

  # Callbacks
  after_save :list_user

  def generate_token
      tokens =  SecureRandom.hex(70)
      self.user_tokens.create(token: tokens)
  end


  #################### Create List
   def list_user
     if !self.list.present?
        self.create_list(title:self.list_name)
     else
         return true
     end
  end


  ############## fetch items in list
  def fetch_items(list)
    self.list.items.all.delete_all
      items =  list.items
      items.each do |i|
        a = self.list.items.find_or_create_by(title: i.data["Title"].to_s, description:i.data["vpts"].to_s,image_url: i.data["image"].to_s ,status:i.data["Status"].humanize, author_id:i.data["AuthorId"].to_s,editor_id:i.data["EditorId"].to_s,item_uri: i.data['__metadata']['uri'], user_name: i.data["user_name"],anonymous: i.data["anonymous"])
          if a.errors.any?
            puts a.errors.full_messages
          end
      end
  end

end

class User < ApplicationRecord


  ####### Associations #########
  has_many :user_tokens

  # Callbacks

  ################### Generate a unique API key
  def generate_token
      tokens =  SecureRandom.hex(70)
      self.user_tokens.create(token: tokens)

  end


  #################### Create List
   def create_list (list)
     if !List.all.present?
        List.create(title:list)
     else
         return true
     end
  end


  ############## fetch items in list
  def fetch_items(list)
      items =  list.items
      items.each do |i|
        a = Item.find_or_create_by(title: i.data["Title"].to_s, description:i.data["vpts"].to_s,image_url: i.data["image"].to_s ,status:i.data["Status"].humanize, author_id:i.data["AuthorId"].to_s,editor_id:i.data["EditorId"].to_s,item_uri: i.data['__metadata']['uri'], user_name: i.data["user_name"],anonymous: i.data["anonymous"])
          if a.errors.any?
            puts a.errors.full_messages
          end
        end
  end
end

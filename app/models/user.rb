class User < ApplicationRecord



  # Callbacks
   before_save do |user| user.api_key = user.generate_api_key end

  ### Constants


  # Generate a unique API key
  def generate_api_key
    loop do
      token = Digest::SHA1.hexdigest([Time.now, rand].join)
      break token unless User.exists?(api_key: token)
    end
  end


  ## Create List
   def create_list (list)
     if !List.all.present?
        List.create(title:list)
     else
         return true
     end
  end


  ## fetch items in list
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

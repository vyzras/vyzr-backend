class User < ApplicationRecord

  #### ASSOCIATIONS ####
  has_many :items


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
      items.each.with_index do |item,index|
        a = self.items.find_or_create_by(title: item.data["Title"].to_s, description:item.data["vpts"].to_s,image_url: item.data["image"].to_s ,status:item.data["Status"].humanize, author_id:item.data["AuthorId"].to_s,editor_id:item.data["EditorId"].to_s,item_uri: item.data['__metadata']['uri'])
          if a.errors.any?
           return a.errors.full_message
          end
        end
      end



end

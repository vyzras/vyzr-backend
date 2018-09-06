class User < ApplicationRecord

  #### ASSOCIATIONS ####
  has_many :items

  # Callbacks
   before_save do |user| user.api_key = user.generate_api_key end
   # before_save :create_list
   # before_save :fetch_items
   # before_save :insertItem

  ### Constants


  # Generate a unique API key
  def generate_api_key
    loop do
      token = Digest::SHA1.hexdigest([Time.now, rand].join)
      break token unless User.exists?(api_key: token)
    end
  end


  ## Create List
   def create_list
     if !List.all.present?
        share_point_lists = VyzrBackend::Application.config.sites.list 'vyzr-Test'
        List.create(title: share_point_lists.title)
     else
         return true
     end

  end


  ## fetch items in list
  def fetch_items

    items =  share_point_lists.items
    items.each do |item|
      a = self.items.create(title: item.data["Title"].to_s, description:item.data["vpts"].to_s,image_url: item.data["image"].to_s ,status:item.data["Status"].to_s, author_id:item.data["AuthorId"].to_s,editor_id:item.data["EditorId"].to_s)
        if a.errors.any?
          puts a.errors.messages
        end
      end
  end


  def insertItem
    begin
      share_point_lists = VyzrBackend::Application.config.sites.list 'vyzr-Test'
      share_point_lists.add_item(title: "heelo")
    rescue Sharepoint::SPException => e
      puts "Sharepoint complained about something: #{e.message}"
      puts "The action that was being executed was: #{e.uri}"
      puts "The request had a body: #{e.request_body}" unless e.request_body.nil?
    end
  end

end

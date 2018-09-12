class Item < ApplicationRecord


  ###### ASSOCIATION ########
  belongs_to :list


  mount_base64_uploader :image_url, ImageUploader


end




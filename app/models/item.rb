class Item < ApplicationRecord


  ###### ASSOCIATION ########
  belongs_to :list

  #####Validation###
  # validates :title ,uniqueness: true , on: :create

end

class Item < ApplicationRecord


  #####Validation###

  validates :title ,uniqueness: true

end

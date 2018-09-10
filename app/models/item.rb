class Item < ApplicationRecord


  #####Validation###
  belongs_to :user
  validates :title ,uniqueness: true

end

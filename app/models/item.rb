class Item < ApplicationRecord


  #####Validation###
  validates :title ,uniqueness: true


  ######

  #### ASSOCIATIONS ####
  belongs_to :user

end

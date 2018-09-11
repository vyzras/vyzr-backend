class List < ApplicationRecord

  #### ASSOCIATIONS ####
  #
  belongs_to :user
  has_many   :items

  end

class User < ApplicationRecord


  ###################### Associations #########################

  has_many :user_tokens
  has_one  :list



  validates :email , uniqueness: true

  #####################  Callbacks    ##########################

  def generate_token
      tokens =  SecureRandom.hex(70)
      self.user_tokens.create(token: tokens)
  end

  #################### Create List
   def list_user(list)
     if !self.list.present?
        self.create_list(title:list)
     else
         return true
     end
   end




end

class User < ApplicationRecord


  ###################### Associations #########################

  has_many :user_tokens
  has_one  :list

  #####################  Callbacks    ##########################

  def generate_token
      tokens =  SecureRandom.hex(70)
      self.user_tokens.create(token: tokens)
  end


  #################### Create List
   def list_user
     if !self.list.present?
        self.create_list(title:self.list_name)
     else
         return true
     end
   end




end

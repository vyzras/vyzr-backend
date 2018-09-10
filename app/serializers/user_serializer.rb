class UserSerializer < ActiveModel::Serializer
  attributes :id , :email   ,:created_at ,:updated_at
  has_many                        :user_token

end

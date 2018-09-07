class ItemSerializer < ActiveModel::Serializer
  attributes :id , :title ,:description, :image_url,:item_uri ,:status ,:updated_at , :user_name , :anonymous
end

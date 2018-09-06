class ItemSerializer < ActiveModel::Serializer
  attributes :id , :title ,:description, :image_url,:user_id,:item_uri ,:status
end

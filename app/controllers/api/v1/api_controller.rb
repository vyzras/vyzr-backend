# app/controllers/api/v1/api_controller.rb

module Api::V1
  class ApiController < ApplicationController
    # Generic API stuff here
    include ActionController::HttpAuthentication::Token::ControllerMethods
    require 'sharepoint/sharepoint-ruby'

    before_action :authenticate

      def authenticate
        authenticate_token || render_unauthorized
      end

      def authenticate_token
        authenticate_with_http_token do |token, options|
          @current_user = User.find_by(api_key: token)
        end
      end

    def create_share_point_user
        site_name=  params[:users][:server_url]
        a = site_name.split('.com/')
        sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
        if sites.session.authenticate   "#{params[:users][:user_name]}", "#{params[:users][:password]}"
          return false
        else
          if list = sites.list(params[:users][:list_name])
          else
            return false
          end
          fetch_items(list)
          return true

        end
    end


      def render_unauthorized(realm = "Application")
        self.headers["WWW-Authenticate"] = %(Token realm="#{realm.gsub(/"/, "")}")
        render json: 'Bad credentials', status: :unauthorized
      end

    def fetch_items(list)
      items =  list.items
      items.each do |i|
        a = Item.find_or_create_by(title: i.data["Title"].to_s, description:i.data["vpts"].to_s,image_url: i.data["image"].to_s ,status:i.data["Status"].humanize, author_id:i.data["AuthorId"].to_s,editor_id:i.data["EditorId"].to_s,item_uri: i.data['__metadata']['uri'], user_name: i.data["user_name"],anonymous: i.data["anonymous"])
        if a.errors.any?
          puts a.errors.full_messages
        end
      end
    end
  #
  end



end
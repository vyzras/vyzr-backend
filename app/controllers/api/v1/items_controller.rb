module Api::V1
  class ItemsController < ApiController
    include ActionController::HttpAuthentication::Token::ControllerMethods
    require 'uri'

    before_action :set_item

    def index
      @items = Item.all
      render json: @items
    end


    def show
      render json: @items
    end

    def update
      sites =  Sharepoint::Site.new "vyzr.sharepoint.com", "sites/mobileapp"
      sites.session.authenticate   @current_user.email, @current_user.password
      list = sites.list('vyzr-test')
      begin
      list_result = list.update_item({Status: params[:items][:Status]}, @items.item_uri)
      rescue Sharepoint::SPException => e
         render json: "Sharepoint complained about something: #{e.message}"
      end
        a =list.get_item(@items.item_uri)
       render :json =>{ID: a.data['ID'],Title: a.data['Title'],Status: a.data['Status'], Description:  a.data['vpts']}
    end


    def updated_list

    end

    def destroy

    end


    def set_item
      @items = Item.find_by(id: params[:id])
    end


  end

end
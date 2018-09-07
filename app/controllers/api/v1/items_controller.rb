module Api::V1
  class ItemsController < ApiController
    include ActionController::HttpAuthentication::Token::ControllerMethods
    skip_before_action :authenticate, only: [:updated_list,:subscription]

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
      puts params
    end


    def subscription
      sites =  Sharepoint::Site.new "vyzr.sharepoint.com", "sites/mobileapp"
      sites.session.authenticate   User.first.email, User.first.password
      list = sites.list('vyzr-test')
      url = list.data["__metadata"]["uri"]
      list.create_subscription(url,'http://vyzrbackend.mashup.li/v1/updated_list')
    end

    def destroy

    end


    def set_item
      @items = Item.find_by(id: params[:id])
    end


  end

end
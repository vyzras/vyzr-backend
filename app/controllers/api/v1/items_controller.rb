module Api::V1
  class ItemsController < ApiController
    include ActionController::HttpAuthentication::Token::ControllerMethods
    skip_before_action :authenticate, only: [:updated_list,:subscription]

    before_action :set_item

    def index
      @user = User.find_by(id: @current_user)
      @items = @user.list.items.all
      render json: {success: true , data: @items }
    end


    def show
      render json: {success: true , data: @items }
    end

    def create
         @user = User.find_by(id: @current_user)
         site_name=  @user.server_url
         a = site_name.split('.com/')
         sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
         sites.session.authenticate   @user.email, @user.password
         list = sites.list(@user.list_name)
         list_result = list.add_item("Title" => "#{params[:items][:title]}", "vpts"=> "#{params[:items][:description]}","anonymous"=> "#{params[:items][:anonymous]}")
         lists = sites.list(@user.list_name)
         @user.fetch_items(lists)
         render json: {success: true , data: Item.last}
        end


    def update
      @user = User.find_by(id: @current_user)
      site_name=  @user.server_url
      a = site_name.split('.com/')
      sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
      sites.session.authenticate   @user.email, @user.password
      list = sites.list(@user.list_name)
      list_result = list.update_item({Status: params[:items][:Status]}, @items.item_uri)
        a =list.get_item(@items.item_uri)
       render :json=>  {success: true , data: {ID: a.data['ID'],Title: a.data['Title'],Status: a.data['Status'], Description:  a.data['vpts']}}
    end


    def updated_list

      if params[:validationToken].present?
        value = params[:validationToken]
        render :json=> value
      else
          resource = ""
          params[:value].each do |d|
          resource = d[:resource]
          end
          @list = List.find_by(guid:resource)
          @user = User.find_by(id:  @list.user_id)
          site_name=  @user.server_url
          a = site_name.split('.com/')
          sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
          sites.session.authenticate   @user.email, @user.password
          list = sites.list(@user.list_name)
           @user.fetch_items(list)
      end

    end


    def subscription
      @user = User.find_by(id: @current_user)
      site_name=  @user.server_url
      a = site_name.split('.com/')
      sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
      sites.session.authenticate   @user.email, @user.password
      list = sites.list(@user.list_name)
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
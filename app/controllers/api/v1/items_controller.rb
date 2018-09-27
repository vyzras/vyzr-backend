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
         @list = @user.list.items.create(title: params[:items][:title], description: params[:items][:description],anonymous: params[:items][:anonymous],:image_url => params[:items][:image])
         if @list.image_url.url.present?
         list_result = list.add_item("Title" => "#{params[:items][:title]}", "vpts"=> "#{params[:items][:description]}","anonymous"=> "#{params[:items][:anonymous]}","image" => "http://vyzrbackend.mashup.li/"+ @list.image_url.url)
         else
         list_result = list.add_item("Title" => "#{params[:items][:title]}", "vpts"=> "#{params[:items][:description]}","anonymous"=> "#{params[:items][:anonymous]}")
         end
         lists = sites.list(@user.list_name)
         fetch_items(lists,@user)
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
          fetch_items(list,@user)
      end

    end


    def destroy

    end

    def fetch_items(list,user)
      user.list.items.all.delete_all
      items =  list.items
      items.each do |i|
        a = user.list.items.find_or_create_by(title: i.data["Title"].to_s, description:i.data["vpts"].to_s,image_url: i.data["image"].to_s ,status:i.data["Status"].humanize, author_id:i.data["AuthorId"].to_s,editor_id:i.data["EditorId"].to_s,item_uri: i.data['__metadata']['uri'], user_name: i.data["user_name"],anonymous: i.data["anonymous"],image_url: i.data["image"])
        if a.errors.any?
          puts a.errors.full_messages
        end
      end
    end

    def set_item
      @items = Item.find_by(id: params[:id])
    end
  end

end
module Api::V1
  class ItemsController < ApiController
    include ActionController::HttpAuthentication::Token::ControllerMethods
    skip_before_action :authenticate, only: [:updated_list,:subscription]
    require 'open-uri'

    before_action :set_item

    # after_action :update_user     , on: [:create]

    def index
        @user = User.find_by(id: @current_user)
        # if @user.is_sync == false
          puts "*****************************************"
          site_name=  @user.server_url
          a = site_name.split('.com/')
          sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
          sites.session.authenticate   @user.email, @user.password
          list = sites.list(@user.list_name)
          b= a[1].split('/')
          site = b[1]
          current_login_user = sites.context_info.current_user.id
          @user.list.items.all.delete_all
          items = list.find_items({orderby: "Created desc &$filter=AuthorId eq #{current_login_user}" }, site)
          fetch_items(items,@user,sites)
          @user.update_attributes(is_sync: true)
        # end
        @items = @user.list.items.all
        render json: {success: true , data: @items   }
        # end
    end



    def show
      @user = User.find_by(id: @current_user)
      site_name=  @user.server_url
      a = site_name.split('.com/')
      sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
      sites.session.authenticate   @user.email, @user.password
      b= a[1].split('/')
      site = b[1]
      list = sites.list(@user.list_name)
      @items = Item.find_by(id: params[:id])
      puts @items.attachment_url
      @items.set_picture(list.show_image(@items.attachment_url,site))
      @items.save!
      render json: {success: true , data: @items }
    end



    def create
         @user = User.find_by(id: @current_user)
         site_name=  @user.server_url
         a = site_name.split('.com/')
         sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
         sites.session.authenticate   @user.email, @user.password
         list = sites.list(@user.list_name)
         b= a[1].split('/')
         site = b[1]
         current_login_user = sites.context_info.current_user.id
         @list = @user.list.items.create(title: params[:items][:title], description: params[:items][:description],:image_url => params[:items][:image])
          list_result = list.add_second_list({"Title" => "#{params[:items][:title]}", "CaseDescription"=> "#{params[:items][:description]}"},site)
         fetch_list_items(list,@user)
         if @list.image_url.present?
           a =(@list.image_url.read)
           list.add_attachment(a, @user.list.items.last.item_uri ,site)
         end
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
       render :json=>  {success: true , data: {ID: a.data['ID'],Title: a.data['Title'],Status: a.data['Status'], Description:  a.data['CaseDescription']}}
    end


    def updated_list

      # if params[:validationToken].present?
      #   render :json=>  params[:validationToken]
      # else
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
          b= a[1].split('/')
          site = b[1]
          current_login_user = sites.context_info.current_user.id
          items = list.find_items({orderby: "Created desc &$filter=AuthorId eq #{current_login_user}" }, site)
          fetch_items(items,@user,sites)
      # end

    end


    def destroy

    end                            

    def fetch_items(list,user,sites)
      site_name=  @user.server_url
      a = site_name.split('.com/')
      b= a[1].split('/')
      site = b[1]
      lists = sites.list(@user.list_name)
      user.list.items.all.delete_all
      list.each do |i|
        if i.attachment_files.present?
          @a = user.list.items.find_or_create_by(title: i.data["Title"].to_s, description:i.data["CaseDescription"].to_s, author_id:i.data["AuthorId"].to_s,editor_id:i.data["EditorId"].to_s,
                                            item_uri: i.data['__metadata']['uri'],complete_percentage: i.data["PercentComplete"],
                                            created_time: i.data["Created"],updated_time: i.data["Modified"],
                                            attachment_url: "https://vyzr.sharepoint.com/"+i.attachment_files.first.server_relative_url)

        else
          user.list.items.find_or_create_by(title: i.data["Title"].to_s, description:i.data["CaseDescription"].to_s, author_id:i.data["AuthorId"].to_s,editor_id:i.data["EditorId"].to_s,item_uri: i.data['__metadata']['uri'],complete_percentage: i.data["PercentComplete"], created_time: i.data["Created"],updated_time: i.data["Modified"])
        end
      end
    end


    def fetch_list_items(list,user)
      site_name=  @user.server_url
      a = site_name.split('.com/')
      b= a[1].split('/')
      site = b[1]
      user.list.items.all.delete_all
      items =  list.items
      items.each do |i|
        if i.attachment_files.present?
       @a = user.list.items.find_or_create_by(title: i.data["Title"].to_s, description:i.data["CaseDescription"].to_s, author_id:i.data["AuthorId"].to_s,editor_id:i.data["EditorId"].to_s,
                                           item_uri: i.data['__metadata']['uri'],complete_percentage: i.data["PercentComplete"],
                                           created_time: i.data["Created"],updated_time: i.data["Modified"],
                                           attachment_url: "https://vyzr.sharepoint.com"+i.attachment_files.first.server_relative_url)

        else
          user.list.items.find_or_create_by(title: i.data["Title"].to_s, description:i.data["CaseDescription"].to_s, author_id:i.data["AuthorId"].to_s,editor_id:i.data["EditorId"].to_s,item_uri: i.data['__metadata']['uri'],complete_percentage: i.data["PercentComplete"], created_time: i.data["Created"],updated_time: i.data["Modified"])
        end
      end
    end


    def set_item
      @items = Item.find_by(id: params[:id])
    end
  end

end
module Api::V1
  class ItemsController < ApiController
    include ActionController::HttpAuthentication::Token::ControllerMethods
    skip_before_action :authenticate, only: [:subscription, :index, :show, :create]
    require 'open-uri'

    before_action :set_item

    def index
        @email = request.headers["email"]
        @password = request.headers["password"]
        @server_url = request.headers["server"]
        @list_name = request.headers["list"]
          site_name =  @server_url
          a = site_name.split('.com/')
          sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
          sites.session.authenticate  @email,  @password
          list = sites.list(@list_name)
          b= a[1].split('/')
          site = b[1]
          current_login_user = sites.context_info.current_user.id
          items = list.find_items({orderby: "Created desc &$filter=AuthorId eq #{current_login_user} &$filter = Created le #{DateTime.now - 31.days} &$select=*" }, site)
          data = []
          items.each do |d|
            data.push(d.data)
          end

      render json: [success:true , data: data]
    end



    def show
      @user = User.find_by(id: @current_user)
      @email = request.headers["email"]
      @password = request.headers["password"]
      @server_url = request.headers["server"]
      @list_name = request.headers["list"]
      @image = request.headers["image"]
      Item.delete_all
      site_name=  @server_url
      a = site_name.split('.com/')
      sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
      sites.session.authenticate @email,@password
      list = sites.list(@list_name)
      b= a[1].split('/')
      site = b[1]
       if @image.present?
      current_login_user = sites.context_info.current_user.id
      items = list.find_items({orderby: "Created desc &$filter=AuthorId eq #{current_login_user} &$filter = Created le #{DateTime.now - 31.days}" }, site)
      items.each do |d|
        if d.attachment_files.present?
          if  d.attachment_files.first.server_relative_url ==  @image.split('.com')[1].to_s
         @item =  Item.create(title: d.data["Title"], description:d.data["CaseDescription"].to_s ,complete_percentage: d.data["PercentComplete"],created_time: d.data["Created"],updated_time:d.data["Modified"] )
         @item.set_picture(list.show_image(@image,site))
          end
        end
      end
          render json: {success: true , data: @item.as_json(:only => [:image_url,:title,:description,:updated_time,:created_time,:complete_percentage])}
       end
    end




    def create
        @email = request.headers["email"]
        @password = request.headers["password"]
        @server_url = request.headers["server"]
        @list_name = request.headers["list"]
         site_name= @server_url
         a = site_name.split('.com/')
         sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
         sites.session.authenticate  @email, @password
         list = sites.list(@list_name)
         b= a[1].split('/')
         site = b[1]
         current_login_user = sites.context_info.current_user.id
         @list = Item.create(title: params[:items][:title], description: params[:items][:description],:image_url => params[:items][:image])
          list_result = list.add_second_list({"Title" => "#{params[:items][:title]}", "CaseDescription"=> "#{params[:items][:description]}"},site)
          fetch_list_items(list)
          if @list.image_url.present?
           a =(@list.image_url.read)
           list.add_attachment(a, Item.last.item_uri ,site)
          end
         render json: {success: true , data: Item.last }
          Item.delete_all

    end


    # def sync(user,email,list_name,server_url,password)
    #        @user = user
    #       site_name = server_url
    #       a = site_name.split('.com/')
    #       sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
    #       sites.session.authenticate  email, password
    #       list = sites.list(list_name)
    #       b= a[1].split('/')
    #       site = b[1]
    #       current_login_user = sites.context_info.current_user.id
    #       items = list.find_items({orderby: "Modified desc &$filter=AuthorId eq #{current_login_user} &$filter = Created le #{DateTime.now - 31.days}" }, site)
    #       if (Time.parse(@user.list.last_updated)).to_i < (Time.parse(items.first.data['Modified'])).to_i
    #         items.each do |d|
    #           if  (Time.parse(@user.list.last_updated)).to_i < (Time.parse(d.data["Modified"])).to_i
    #              puts "**********************************************************************"
    #              puts "**********************************************************************"
    #              puts "**********************************************************************"
    #              puts "**********************************************************************"
    #              if @items =  @user.list.items.find_by(item_uri: d.data["__metadata"]["uri"])
    #                   if d.attachment_files.present?
    #                     @items.update_attributes(title: d.data["Title"].to_s, description:d.data["CaseDescription"].to_s,
    #                                              author_id:d.data["AuthorId"].to_s,editor_id:d.data["EditorId"].to_s,
    #                                              item_uri: d.data['__metadata']['uri'],complete_percentage: d.data["PercentComplete"],
    #                                              created_time: d.data["Created"],updated_time: d.data["Modified"],
    #                                              attachment_url: "https://vyzr.sharepoint.com/"+d.attachment_files.first.server_relative_url)
    #                   else
    #                     @items.update_attributes(title: d.data["Title"].to_s, description:d.data["CaseDescription"].to_s,
    #                                              author_id:d.data["AuthorId"].to_s,editor_id:d.data["EditorId"].to_s,
    #                                              item_uri: d.data['__metadata']['uri'],complete_percentage: d.data["PercentComplete"],
    #                                              created_time: d.data["Created"],updated_time: d.data["Modified"])
    #                   end
    #              else
    #                    @not_present =  @user.list.items.find_by(item_uri: d.data["__metadata"]["uri"])
    #                     if @not_present.nil?
    #                       if d.attachment_files.present?
    #                       @user.list.items.create(title: d.data["Title"].to_s, description:d.data["CaseDescription"].to_s, author_id:d.data["AuthorId"].to_s,editor_id:d.data["EditorId"].to_s,
    #                                                item_uri: d.data['__metadata']['uri'],complete_percentage: d.data["PercentComplete"],
    #                                                created_time: d.data["Created"],updated_time: d.data["Modified"],
    #                                               attachment_url: "https://vyzr.sharepoint.com/"+d.attachment_files.first.server_relative_url)
    #                       else
    #                         @user.list.items.create(title: d.data["Title"].to_s, description:d.data["CaseDescription"].to_s, author_id:d.data["AuthorId"].to_s,editor_id:d.data["EditorId"].to_s,
    #                                                 item_uri: d.data['__metadata']['uri'],complete_percentage: d.data["PercentComplete"],
    #                                                 created_time: d.data["Created"],updated_time: d.data["Modified"])
    #                       end
    #                     end
    #              puts "#######################################################################"
    #              puts "#######################################################################"
    #              puts "#######################################################################"
    #              puts "#######################################################################"
    #           end
    #             @user.list.update_attributes(last_updated:  items.first.data['Modified'])
    #           end
    #         end
    #
    #       else
    #         puts  (Time.parse(@user.list.last_updated)).to_i
    #         puts  (Time.parse(items.first.data['Modified'])).to_i
    #
    #       end
    # end



    def destroy

    end


    def fetch_list_items(list)
      Item.delete_all
      items =  list.items
      items.each do |i|
        if i.attachment_files.present?
       @a = Item.find_or_create_by(title: i.data["Title"].to_s, description:i.data["CaseDescription"].to_s, author_id:i.data["AuthorId"].to_s,editor_id:i.data["EditorId"].to_s,
                                           item_uri: i.data['__metadata']['uri'],complete_percentage: i.data["PercentComplete"],
                                           created_time: i.data["Created"],updated_time: i.data["Modified"],
                                           attachment_url: "https://vyzr.sharepoint.com"+i.attachment_files.first.server_relative_url,
                                          item_id: i.data['__metadata']['id'])

        else
         Item.find_or_create_by(title: i.data["Title"].to_s, description:i.data["CaseDescription"].to_s, author_id:i.data["AuthorId"].to_s,editor_id:i.data["EditorId"].to_s,item_uri: i.data['__metadata']['uri'],complete_percentage: i.data["PercentComplete"], created_time: i.data["Created"],updated_time: i.data["Modified"],
                                            item_id: i.data['__metadata']['id'])
        end
      end
    end


    def set_item
      @items = Item.find_by(id: params[:id])
    end
  end

end
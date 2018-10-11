module Api::V1
  class UsersController < ApiController


    ########################## CALLBACK #################################

    skip_before_action :authenticate, only: [:sign_in]

    before_action :set_user ,on: [:show,:index]

    ########################## CALLBACK #################################



    def index
     render json: {success: true , data: { user: @user.as_json(:except => [:created_at, :updated_at,:api_key,:first_name,:last_name]) ,user_token: @user.user_tokens.last.token}}
    end

    def sign_in
      @user =  User.find_or_create_by(email:params[:users][:user_name],password:params[:users][:password],server_url: params[:users][:server_url] )
      @user.server_url = params[:users][:server_url]
      @user.list_name  = params[:users][:list_name]
       if create_share_point_user
         site_name=  params[:users][:server_url]
         a = site_name.split('.com/')
         sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
         sites.session.authenticate   params[:users][:user_name], params[:users][:password]
         list = sites.list(params[:users][:list_name])
         @user.list_user
         subscription(@user)
         if @user.list.items.present?
           @user.list.items.all.delete_all
           fetch_list_items(list,@user)
         else
           fetch_list_items(list,@user)
         end
         @user.generate_token
         @user.save!
         @user.list.update_attributes(guid: list.guid)
         render json: {success: true , data: { user: @user.as_json(:except => [:created_at, :updated_at,:api_key,:first_name,:last_name]) ,user_token: @user.user_tokens.last.token}}
       else
         render json: {success: false , error: @user.errors.full_messages.to_sentence }
       end
      end


    def show
        render json: {success: true , data: @user.as_json(:include => { :user_tokens =>  { :only => :token }}) }
    end


    def set_user
    @user = User.find_by(id: @current_user)
    end

    def fetch_list_items(list,user)
      user.list.items.all.delete_all
      items =  list.items
      items.each do |i|
        if i.attachment_files.present?
          user.list.items.find_or_create_by(title: i.data["Title"].to_s, description:i.data["CaseDescription"].to_s, author_id:i.data["AuthorId"].to_s,editor_id:i.data["EditorId"].to_s,
                                            item_uri: i.data['__metadata']['uri'],complete_percentage: i.data["PercentComplete"],
                                            created_time: i.data["Created"],updated_time: i.data["Modified"],
                                            attachment_url: "https://vyzr.sharepoint.com/"+i.attachment_files.first.server_relative_url)
        else
          user.list.items.find_or_create_by(title: i.data["Title"].to_s, description:i.data["CaseDescription"].to_s, author_id:i.data["AuthorId"].to_s,editor_id:i.data["EditorId"].to_s,item_uri: i.data['__metadata']['uri'],complete_percentage: i.data["PercentComplete"], created_time: i.data["Created"],updated_time: i.data["Modified"])
        end
      end
    end

    def subscription(user)
      if user.subscribed == false
        site_name=  user.server_url
        a = site_name.split('.com/')
        sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
        sites.session.authenticate   user.email, user.password
        list = sites.list(user.list_name)
        b= a[1].split('/')
        site = b[1]
        url = list.data["__metadata"]["uri"]
        list.create_subscription(url,'http://vyzrbackend.mashup.li/v1/updated_list',site )
        user.update_attributes(subscribed:  true)
      else
        return true
      end
    end


  end
end
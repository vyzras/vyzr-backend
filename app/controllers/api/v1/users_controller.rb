module Api::V1
  class UsersController < ApiController
    skip_before_action :authenticate, only: [:sign_in]
    before_action :set_user ,on: [:show,:index]
    require 'sharepoint/sharepoint-ruby'

    def index
     render json: {success: true , data: { user: @user.as_json(:except => [:created_at, :updated_at,:api_key,:first_name,:last_name]) ,user_token: @user.user_tokens.last.token}}
    end

    def sign_in
      @user =  User.find_or_create_by(email:params[:users][:user_name],password:params[:users][:password] )
      @user.server_url = params[:users][:server_url]
      @user.list_name  = params[:users][:list_name]
       if create_share_point_user
         site_name=  params[:users][:server_url]
         a = site_name.split('.com/')
         sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
         sites.session.authenticate   params[:users][:user_name], params[:users][:password]
         list = sites.list(params[:users][:list_name])
         @user.list_user
         @user.fetch_items(list)
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

  end
end
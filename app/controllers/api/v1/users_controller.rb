module Api::V1
  class UsersController < ApiController
    skip_before_action :authenticate, only: [:sign_in]

    require 'sharepoint/sharepoint-ruby'

    def index
     @user = User.all
     render json: {success: true , data: @user }
    end

    def sign_in
      @user =  User.find_or_create_by(email:params[:users][:user_name],password:params[:users][:password] )
      @user.server_url = params[:users][:server_url]
      @user.list_name  = params[:users][:list_name]
      @user.save!
       if create_share_point_user
         render json: {success: true , data: @user}
       else
         render json: {success: false , error:"User Name or Email doesn't Exist"}
       end
      end


    def show
      render json: {success: true , data: @user }
    end


  end
end
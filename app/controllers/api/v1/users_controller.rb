module Api::V1
  class UsersController < ApiController
    skip_before_action :authenticate, only: [:sign_in]

    require 'sharepoint/sharepoint-ruby'

    def index
     @user = User.all
     render json: {success: true , data: @user }
    end

    def sign_in
      @user =  User.find_or_create_by(email:params[:users][:user_name] , password:params[:users][:password] )
      sites =  Sharepoint::Site.new "vyzr.sharepoint.com", "sites/mobileapp"
       if sites.session.authenticate   "#{params[:users][:user_name]}", "#{params[:users][:password]}"
         render json: {success: true , error => "User Name or Email doesn't Exist"}
       else
         render json: {success: true , data: @user}
       end
      end

    def show
      render json: {success: true , data: @user }
    end


  end
end
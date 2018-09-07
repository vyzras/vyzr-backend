module Api::V1
  class UsersController < ApiController
    skip_before_action :authenticate, only: [:sign_in]

    require 'sharepoint/sharepoint-ruby'

    def index
     @user = User.all
      render json: @user
    end

    def sign_in
      @user =  User.find_or_create_by(email:params[:users][:user_name] , password:params[:users][:password] )
      sites =  Sharepoint::Site.new "vyzr.sharepoint.com", "sites/mobileapp"
      sites.session.authenticate   "#{params[:users][:user_name]}", "#{params[:users][:password]}"
      list = sites.list('vyzr-test')
      @user.create_list(list.title)
      @user.fetch_items(list)
      if @user.save
         render json: {success: true , data: @user}
       else
         render json: @user.errors.full_messages.to_sentence
      end
    end

    def show
     render json: @current_user
    end


  end
end
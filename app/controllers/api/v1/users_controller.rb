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
         site_name =     params[:users][:server_url]
         a = site_name.split('.com/')
         sites =  Sharepoint::Site.new a[0]+ ".com", a[1]
         data =  sites.session.authenticate     params[:users][:user_name],  params[:users][:password]
         list = sites.list(params[:users][:list_name])

         if data.nil?
           render json: {success: true }
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
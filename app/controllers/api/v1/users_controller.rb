module Api::V1
  class UsersController < ApiController
    include ActionController::HttpAuthentication::Token::ControllerMethods
    require 'sharepoint/sharepoint-ruby'
    before_action :authenticate , only: [:index, :show]

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
      # list.update_item({Status: "Resolved"}, url)
      if @user.save
         render json: @user
       else
         render json: @user.errors.full_messages.to_sentence
      end
    end

    def show
     render json: @current_user
    end


    protected
    # Authenticate the user with token based authentication
    def authenticate
      authenticate_token || render_unauthorized
    end

    def authenticate_token
      authenticate_with_http_token do |token, options|
        @current_user = User.find_by(api_key: token)
      end
    end

    def render_unauthorized(realm = "Application")
      self.headers["WWW-Authenticate"] = %(Token realm="#{realm.gsub(/"/, "")}")
      render json: 'Bad credentials', status: :unauthorized
    end

  end
end
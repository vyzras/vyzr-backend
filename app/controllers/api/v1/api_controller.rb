# app/controllers/api/v1/api_controller.rb

module Api::V1
  class ApiController < ApplicationController
    # Generic API stuff here
    include ActionController::HttpAuthentication::Token::ControllerMethods
    require 'sharepoint/sharepoint-ruby'
    require 'sharepoint/sharepoint-session'

    ### Exception Handling ######
    rescue_from Sharepoint::Session::AuthenticationFailed, with: :show_response_error
    rescue_from Sharepoint::Session::UnknownAuthenticationError, with: :show_response_error
    rescue_from Sharepoint::SPException, with: :show_response_error
    rescue_from ActiveRecord::RecordInvalid, with: :show_response_error


    ##### Exception Handling Method #########
    def show_response_error(exception)
      render json: { error: exception.message }, status: :not_found
    end




    ######## call Back ##############
    before_action :authenticate



    ##### Authentication API ###############
        def authenticate
          authenticate_token || render_unauthorized
        end

        def authenticate_token
            authenticate_with_http_token do |token, options|
                if user = UserToken.find_by(token: token)
                @current_user = user.user_id
                else
                  return false
                end
            end
          end


        def render_unauthorized(realm = "Application")
          self.headers["WWW-Authenticate"] = %(realm="#{realm.gsub(/"/, "")}")
          render json: {success: false , error: "User Authorization Failed , No Valid Token Present"}
        end


    ############## SharePoint Authentication #################


end
end


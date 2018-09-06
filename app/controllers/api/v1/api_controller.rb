# app/controllers/api/v1/api_controller.rb

module Api::V1
  class ApiController < ApplicationController
    # Generic API stuff here
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate

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
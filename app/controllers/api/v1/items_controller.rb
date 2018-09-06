module Api::V1
  class ItemsController < ApiController
    include ActionController::HttpAuthentication::Token::ControllerMethods


    def index
      @items = @current_user.items.all
      render json: @items
    end


    def create
    end


    def update

    end



    def destroy

    end


  end

end
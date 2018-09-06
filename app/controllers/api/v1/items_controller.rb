module Api::V1
  class ItemController < ApiController
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate


    def index

    end


    def create
    end


    def update

    end



    def destroy

    end


  end

end
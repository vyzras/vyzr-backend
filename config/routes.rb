Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

    scope module: 'api' do
      namespace :v1 do
        resources :users
        match 'sign_in', to: "users#sign_in" , as: :sharepoint_login , via: [:get, :post]
        resources :items
      end
    end


end
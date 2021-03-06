Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

    scope module: 'api' do
      namespace :v1 do
        resources :users
        match 'sign_in', to: "users#sign_in" , as: :sharepoint_login , via: [:get, :post]
        resources :items
        match 'sync', to: "items#sync" , as: :sync_data , via: [:get]
        match 'subscription', to: "items#subscription" , as: :subscription , via: [:get]

      end
    end

end
Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :activities, only: [] do
    collection do
      get :available
      get :recommend
    end
  end
end

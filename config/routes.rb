Demand::Application.routes.draw do
  root :to => "demander#index"

  resources :organisation_manager do
    collection do
      get :search
    end
  end

  resources :demander do
    collection do
      post :search
      match :upload_demands 
    end
  end

end

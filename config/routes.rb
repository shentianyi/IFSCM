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
    end
  end

  controller :demander do
    match 'demander/upload_demands'=>:upload_demands
  end

end

Demand::Application.routes.draw do
  root :to => "demand_forecast#index"

  resources :organisation_manager do
    collection do
      get :search
    end
  end

  resources :demand_forecast do
    collection do
      post :search
    end
  end

  controller :demander do
    match 'demander/upload_demands'=>:upload_demands
  end

end

Demand::Application.routes.draw do
  root :to => "demander#index"

  resources :organisation_manager do
    collection do
      get :search
      post :add_supplier
    end
  end

  resources :demander do
    collection do
      post :search
      match :upload_files
      match :get_error
      match :get_normal
      match :correct_error
      match :cancel_upload
      match :demand_history
    end
  end
  
  resources :part do
    collection do
     get :searcher
     get :search
    end
  end

  mount Resque::Server.new, :at=>"/admin/resque"
end

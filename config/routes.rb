Demand::Application.routes.draw do
  root :to => "demander#index"

  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    get 'logout' => :destroy
  end

  resources :organisation_manager do
    collection do
      get :search
      post :add_supplier
    end
  end

  resources :demander do
    collection do
      post :search
      get :demand_upload
      match :upload_files
      post :get_tempdemand_items
      match :correct_error
      match :cancel_upload
      match :demand_history
    end
  end
  
  resources :part do
    collection do
     get :searcher
     get :redis_search
     
    end
  end

  mount Resque::Server.new, :at=>"/admin/resque"
end

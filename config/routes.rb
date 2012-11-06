Demand::Application.routes.draw do
  root :to => "sessions#new"

  controller :welman do
    get 'welcome' => :index
  end
  
  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    get 'logout' => :destroy
    post 'activate' => :org_type_activate
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
      post :correct_error
      post :cancel_upload
      match :demand_history
      post :download
      post :send_demand
      get :data_analysis
      post :data_chart
    end
  end
#    
   # controller :demander do
     # post 'create'=>:create
   # end
#    
  resources :part do
    collection do
     get :searcher
     get :redis_search
     
    end
  end

  mount Resque::Server.new, :at=>"/admin/resque"
end

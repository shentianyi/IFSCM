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
    get 'sessions/reload'=> :reload
  end

  controller :organisation_manager do
    get 'organisation_manager' => :index
    match 'organisation_manager/search' => :search
    get 'organisation_manager/redis_search' => :redis_search
    post 'organisation_manager/add_supplier' => :add_supplier
    post 'organisation_manager/add_client' => :add_client
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
      post :kestrel_newer
      match :data_analysis
      post :data_chart
      post :check_staff_cache_file
      post :check_staff_unfinished_file
      post :clean_staff_cache_file
      post :get_cache_file_info
      post :handle_batch
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
     post :get_parts_by_partnerNr
    end
  end

  mount Resque::Server.new, :at=>"/admin/resque"
end

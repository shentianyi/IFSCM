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
    match 'organisation_manager/edit' => :edit
    match 'organisation_manager/search' => :search
    get 'organisation_manager/redis_search' => :redis_search
    post 'organisation_manager/add_supplier' => :add_supplier
  end

  resources :demander do
    collection do
      post :search
      match :search_expired
      post :demand_transform_delivery
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
      post :download_viewed_demand
    end
  end

  resources :part do
    collection do
      get :searcher
      get :redis_search
      post :get_partRels
      match :redis_search_meta
    end
  end

  resources :delivery do
    collection do
      match :pick_part
      match :view_pend_dn
      post :send_delivery
      post :get_dit_dn_cache
      post :add_di_temp
      post :delete_dit
      post :build_dn
      match :view_pend_dn
      post :cancel_staff_dn
      post :count_dn_queue
      post :clean_dn_queue
      post :search_dn
      get :redis_search_dn
      post :add_to_print
      match :gen_dn_pdf
      post :update_dit
      match :check_dit_list
      post :clean_dit
    end
  end

  namespace :api,defaults:{format:'json'} do
    # scope  constraints:ApiConstraints.new do
      controller :auth do
        match 'login'=>:login
     end
     controller :delivery do
       match 'delivery/print_queue_list'=>:print_queue_list
       match 'delivery/remove_from_print_queue'=>:remove_from_print_queue
       match 'delivery/package_list'=>:package_list
       match 'delivery/item_list/'=>:item_list
       match 'delivery/item_print_data' => :item_print_data
     end
    #end
  end

  mount Resque::Server.new, :at=>"/admin/resque"
end

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
    match 'organisation_manager/new' => :new
    get 'organisation_manager/manager' => :manager
    post 'organisation_manager/create_staff' => :create_staff
    post 'organisation_manager/create_org_relation' => :create_org_relation
    post 'organisation_manager/create_relpart' => :create_relpart
    post 'organisation_manager/create_relpart_package' => :create_relpart_package
    post 'organisation_manager/create_relpart_check' => :create_relpart_check
    match 'organisation_manager/search' => :search
    get 'organisation_manager/redis_search' => :redis_search
    match 'organisation_manager/delivery_set'=>:delivery_set
    match 'organisation_manager/get_printer'=>:get_printer
    match 'organisation_manager/add_printer'=>:add_printer
    match 'organisation_manager/del_printer'=>:del_printer
    match 'organisation_manager/add_default_printer'=>:add_default_printer
    match 'organisation_manager/update_default_printer'=>:update_default_printer
    match 'organisation_manager/get_dncontact'=>:get_dncontact
    match 'organisation_manager/add_dncontact'=>:add_dncontact
    match 'organisation_manager/del_dncontact'=>:del_dncontact
    match 'organisation_manager/upload_printer_template'=>:upload_printer_template
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
      get :dn_detail
      match :accept      
      post :doaccept
      match :inspect
      post :doinspect      
      post :mark_abnormal
      match :instore
      post :doinstore
      post :return_dn
    end
  end
  
  controller :warehouse do
    match "warehouse/stock_out" => :stock_out
    post "warehouse/stock_out_list" => :stock_out_list
    match "warehouse/primary_warehouse" => :primary_warehouse
    post "warehouse/delete_warehouse" => :delete_warehouse
    match "warehouse/primary_position" => :primary_position
    post "warehouse/new_position_range" => :new_position_range
    post "warehouse/new_position_single" => :new_position_single
    post "warehouse/delete_position" => :delete_position
    match "warehouse/search_state" => :search_state
    match "warehouse/search_op_history" => :search_op_history
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
      match 'delivery/updated_template' =>:updated_template
    end
  #end
  end

  mount Resque::Server.new, :at=>"/admin/resque"
end

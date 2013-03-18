# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130313125727) do

  create_table "cost_centers", :force => true do |t|
    t.string   "name"
    t.string   "desc"
    t.integer  "organisation_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "cost_centers", ["organisation_id"], :name => "index_cost_centers_on_organisation_id"

  create_table "delivery_item_states", :force => true do |t|
    t.integer  "state",            :default => 100
    t.string   "desc"
    t.integer  "delivery_item_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "delivery_item_states", ["delivery_item_id"], :name => "index_delivery_item_states_on_delivery_item_id"

  create_table "delivery_items", :force => true do |t|
    t.string   "key"
    t.integer  "state",               :default => 100
    t.string   "parentKey"
    t.integer  "delivery_package_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "wayState",            :default => 100
    t.boolean  "checked",             :default => false
    t.boolean  "stored",              :default => false
    t.string   "posi"
  end

  add_index "delivery_items", ["delivery_package_id"], :name => "index_delivery_items_on_delivery_package_id"

  create_table "delivery_notes", :force => true do |t|
    t.string   "key"
    t.integer  "wayState"
    t.integer  "rece_org_id"
    t.string   "destination"
    t.integer  "state",           :default => 100
    t.datetime "sendDate"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "staff_id"
    t.integer  "organisation_id"
  end

  add_index "delivery_notes", ["organisation_id"], :name => "index_delivery_notes_on_organisation_id"
  add_index "delivery_notes", ["staff_id"], :name => "index_delivery_notes_on_staff_id"

  create_table "delivery_packages", :force => true do |t|
    t.string   "key"
    t.string   "saleNo"
    t.string   "purchaseNo"
    t.string   "cpartNr"
    t.string   "spartNr"
    t.string   "parentKey"
    t.integer  "part_rel_id"
    t.integer  "packAmount"
    t.float    "perPackAmount"
    t.integer  "delivery_note_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "orderNr"
    t.integer  "order_item_id"
  end

  add_index "delivery_packages", ["delivery_note_id"], :name => "index_delivery_packages_on_delivery_note_id"
  add_index "delivery_packages", ["order_item_id"], :name => "index_delivery_packages_on_order_item_id"
  add_index "delivery_packages", ["part_rel_id"], :name => "index_delivery_packages_on_part_rel_id"

  create_table "demanders", :force => true do |t|
    t.string   "key"
    t.integer  "clientId"
    t.integer  "supplierId"
    t.integer  "relpartId"
    t.string   "type"
    t.float    "amount"
    t.float    "oldamount"
    t.datetime "date"
    t.float    "rate"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "orderNr"
    t.integer  "order_item_id"
  end

  create_table "order_items", :force => true do |t|
    t.string   "orderNr"
    t.decimal  "total",           :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "rest",            :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "transit",         :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "receipt",         :precision => 15, :scale => 2, :default => 0.0
    t.string   "demander_key"
    t.integer  "organisation_id"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.integer  "supplier_id"
  end

  create_table "organisation_relations", :force => true do |t|
    t.string   "supplierNr"
    t.string   "clientNr"
    t.integer  "origin_supplier_id"
    t.integer  "origin_client_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "organisations", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "address"
    t.string   "tel"
    t.string   "website"
    t.string   "abbr"
    t.string   "contact"
    t.string   "email"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "part_rels", :force => true do |t|
    t.string   "saleNo"
    t.string   "purchaseNo"
    t.integer  "client_part_id"
    t.integer  "supplier_part_id"
    t.integer  "organisation_relation_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "part_rels", ["organisation_relation_id"], :name => "index_part_rels_on_organisation_relation_id"

  create_table "parts", :force => true do |t|
    t.string   "partNr"
    t.integer  "organisation_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "parts", ["organisation_id"], :name => "index_parts_on_organisation_id"

  create_table "positions", :force => true do |t|
    t.string   "nr"
    t.integer  "capacity"
    t.integer  "warehouse_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "positions", ["warehouse_id"], :name => "index_positions_on_warehouse_id"

  create_table "staffs", :force => true do |t|
    t.string   "staffNr"
    t.string   "name"
    t.integer  "orgId"
    t.string   "salt"
    t.string   "pwd"
    t.integer  "organisation_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "staffs", ["organisation_id"], :name => "index_staffs_on_organisation_id"

  create_table "storage_histories", :force => true do |t|
    t.integer  "opType"
    t.decimal  "amount",           :precision => 15, :scale => 2
    t.integer  "position_id"
    t.integer  "part_id"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "cost_center_name"
  end

  create_table "storages", :force => true do |t|
    t.decimal  "stock",            :precision => 15, :scale => 2
    t.integer  "position_id"
    t.integer  "part_id"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.integer  "delivery_item_id"
    t.integer  "state",                                           :default => 100
  end

  add_index "storages", ["part_id"], :name => "index_storages_on_part_id"
  add_index "storages", ["position_id"], :name => "index_storages_on_position_id"

  create_table "strategies", :force => true do |t|
    t.integer  "leastAmount"
    t.integer  "part_rel_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "needCheck",          :default => 100
    t.boolean  "demote",             :default => false
    t.integer  "demote_times",       :default => 1
    t.integer  "position_id"
    t.integer  "check_passed_times", :default => 0
  end

  add_index "strategies", ["part_rel_id"], :name => "index_strategies_on_part_rel_id"

  create_table "warehouses", :force => true do |t|
    t.string   "nr"
    t.string   "name"
    t.integer  "organisation_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "type",            :default => 100
    t.integer  "state"
  end

  add_index "warehouses", ["organisation_id"], :name => "index_warehouses_on_organisation_id"

end

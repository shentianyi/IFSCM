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

ActiveRecord::Schema.define(:version => 20130201133248) do

  create_table "delivery_items", :force => true do |t|
    t.string   "key"
    t.integer  "state"
    t.string   "parentKey"
    t.integer  "delivery_package_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "delivery_items", ["delivery_package_id"], :name => "index_delivery_items_on_delivery_package_id"

  create_table "delivery_notes", :force => true do |t|
    t.string   "key"
    t.integer  "wayState"
    t.integer  "rece_org_id"
    t.string   "destination"
    t.integer  "state"
    t.datetime "sendDate"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
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
    t.integer  "partRelId"
    t.integer  "packAmount"
    t.float    "perPackAmount"
    t.integer  "delivery_note_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "delivery_packages", ["delivery_note_id"], :name => "index_delivery_packages_on_delivery_note_id"

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
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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

  create_table "package_infos", :force => true do |t|
    t.integer  "leastAmount"
    t.integer  "part_rel_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "package_infos", ["part_rel_id"], :name => "index_package_infos_on_part_rel_id"

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

end

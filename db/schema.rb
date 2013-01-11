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

ActiveRecord::Schema.define(:version => 20130109035942) do

  create_table "m_delivery_items", :force => true do |t|
    t.string   "key"
    t.integer  "state"
    t.integer  "amount"
    t.string   "parentKey"
    t.string   "saleNo"
    t.string   "purchaseNo"
    t.string   "cpartNr"
    t.string   "spartNr"
    t.string   "partRelMetaKey"
    t.integer  "m_delivery_note_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "m_delivery_items", ["m_delivery_note_id"], :name => "index_m_delivery_items_on_m_delivery_note_id"

  create_table "m_delivery_notes", :force => true do |t|
    t.string   "key"
    t.integer  "wayState"
    t.integer  "orgId"
    t.integer  "sender"
    t.integer  "desiOrgId"
    t.string   "destination"
    t.integer  "state"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "sendDate"
  end

  create_table "staffs", :force => true do |t|
    t.string   "staffNr"
    t.string   "name"
    t.integer  "orgId"
    t.string   "salt"
    t.string   "pwd"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end

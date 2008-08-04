# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080801124527) do

  create_table "artic_files", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "file_path"
    t.boolean  "private",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audios", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "file_path"
    t.boolean  "private",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "file_path"
    t.boolean  "private",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.string   "itemable_type"
    t.integer  "itemable_id",   :limit => 11
    t.integer  "workspace_id",  :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions_roles", :force => true do |t|
    t.integer  "role_id",       :limit => 11
    t.integer  "permission_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public_items", :force => true do |t|
    t.integer  "itemable_id",          :limit => 11
    t.string   "itemable_type"
    t.integer  "extranet_category_id", :limit => 11
    t.integer  "suggester_id",         :limit => 11
    t.integer  "validated",            :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "addr",                      :limit => 500
    t.string   "laboratory"
    t.string   "phone"
    t.string   "mobile"
    t.string   "activity"
    t.text     "edito"
    t.string   "image_path",                :limit => 500
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.integer  "system_role_id",            :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  create_table "users_workspaces", :force => true do |t|
    t.integer  "workspace_id", :limit => 11
    t.integer  "role_id",      :limit => 11
    t.integer  "user_id",      :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "file_path"
    t.boolean  "private",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workspaces", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

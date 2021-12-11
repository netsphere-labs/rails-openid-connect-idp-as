# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2012_02_29_153919) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_token_request_objects", force: :cascade do |t|
    t.bigint "access_token_id"
    t.bigint "request_object_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["access_token_id"], name: "index_access_token_request_objects_on_access_token_id"
    t.index ["request_object_id"], name: "index_access_token_request_objects_on_request_object_id"
  end

  create_table "access_token_scopes", id: :serial, force: :cascade do |t|
    t.integer "access_token_id"
    t.integer "scope_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "access_tokens", id: :serial, force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "fake_user_id", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["token"], name: "index_access_tokens_on_token", unique: true
  end

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string "last_login_from_ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_accounts_on_email", unique: true
  end

  create_table "authorization_request_objects", force: :cascade do |t|
    t.bigint "authorization_id"
    t.bigint "request_object_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["authorization_id"], name: "index_authorization_request_objects_on_authorization_id"
    t.index ["request_object_id"], name: "index_authorization_request_objects_on_request_object_id"
  end

  create_table "authorization_scopes", id: :serial, force: :cascade do |t|
    t.integer "authorization_id", null: false
    t.integer "scope_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authorizations", id: :serial, force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "fake_user_id", null: false
    t.string "code", null: false
    t.string "nonce"
    t.string "redirect_uri"
    t.datetime "expires_at", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_authorizations_on_code", unique: true
  end

  create_table "clients", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.string "name", null: false
    t.string "identifier", null: false
    t.string "secret", null: false
    t.string "jwks_uri"
    t.string "sector_identifier"
    t.string "redirect_uris"
    t.boolean "dynamic", default: false
    t.boolean "native", default: false
    t.boolean "ppid", default: false
    t.datetime "expires_at"
    t.text "raw_registered_json"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["identifier"], name: "index_clients_on_identifier", unique: true
  end

  create_table "connect_facebook", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "identifier", null: false
    t.string "access_token", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["access_token"], name: "index_connect_facebook_on_access_token", unique: true
    t.index ["identifier"], name: "index_connect_facebook_on_identifier", unique: true
  end

  create_table "connect_google", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "identifier", null: false
    t.string "access_token", null: false
    t.text "id_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["access_token"], name: "index_connect_google_on_access_token", unique: true
    t.index ["identifier"], name: "index_connect_google_on_identifier", unique: true
  end

  create_table "fake_users", force: :cascade do |t|
    t.string "identifier", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "address"
    t.string "profile"
    t.string "locale"
    t.string "phone_number"
    t.boolean "verified", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_fake_users_on_email", unique: true
    t.index ["identifier"], name: "index_fake_users_on_identifier", unique: true
  end

  create_table "id_token_request_objects", force: :cascade do |t|
    t.bigint "id_token_id"
    t.bigint "request_object_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["id_token_id"], name: "index_id_token_request_objects_on_id_token_id"
    t.index ["request_object_id"], name: "index_id_token_request_objects_on_request_object_id"
  end

  create_table "id_tokens", id: :serial, force: :cascade do |t|
    t.integer "fake_user_id", null: false
    t.integer "client_id", null: false
    t.string "nonce"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pairwise_pseudonymous_identifiers", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.string "identifier"
    t.string "sector_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "request_objects", force: :cascade do |t|
    t.text "jwt_string"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "scopes", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_scopes_on_name", unique: true
  end

  add_foreign_key "connect_facebook", "accounts"
  add_foreign_key "connect_google", "accounts"
end

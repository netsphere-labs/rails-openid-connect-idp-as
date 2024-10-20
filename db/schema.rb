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

ActiveRecord::Schema[7.2].define(version: 2024_07_01_053728) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_token_scopes", id: :serial, force: :cascade do |t|
    t.integer "access_token_id", null: false
    t.integer "scope_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["access_token_id", "scope_id"], name: "index_access_token_scopes_on_access_token_id_and_scope_id", unique: true
  end

  create_table "access_tokens", id: :serial, force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "fake_user_id", null: false
    t.string "token", null: false
    t.datetime "expires_at", precision: nil, null: false
    t.integer "request_object_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["token"], name: "index_access_tokens_on_token", unique: true
  end

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "last_login_at", precision: nil, comment: "明示的にログインしたときのみ記録される"
    t.string "last_login_from_ip_address"
    t.datetime "last_logout_at", precision: nil
    t.datetime "last_activity_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_accounts_on_email", unique: true
  end

  create_table "authorization_scopes", id: :serial, force: :cascade do |t|
    t.integer "authorization_id", null: false
    t.integer "scope_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["authorization_id", "scope_id"], name: "index_authorization_scopes_on_authorization_id_and_scope_id", unique: true
  end

  create_table "authorizations", id: :serial, force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "fake_user_id", null: false
    t.string "code", null: false
    t.string "nonce"
    t.string "redirect_uri"
    t.datetime "expires_at", precision: nil, null: false
    t.integer "request_object_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "code_challenge"
    t.index ["code"], name: "index_authorizations_on_code", unique: true
  end

  create_table "clients", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.string "name", null: false
    t.string "identifier", null: false
    t.string "secret", null: false
    t.string "jwks_uri"
    t.string "redirect_uris"
    t.boolean "dynamic", default: false
    t.boolean "native", default: false
    t.boolean "ppid", default: false
    t.string "sector_identifier"
    t.datetime "expires_at", precision: nil
    t.text "raw_registered_json"
    t.string "client_public_keys"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["identifier"], name: "index_clients_on_identifier", unique: true
  end

  create_table "connect_google", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "identifier", null: false
    t.string "access_token", null: false
    t.text "id_token"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
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
    t.boolean "email_verified", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_fake_users_on_email", unique: true
    t.index ["identifier"], name: "index_fake_users_on_identifier", unique: true
  end

  create_table "id_tokens", id: :serial, force: :cascade do |t|
    t.integer "fake_user_id", null: false
    t.integer "client_id", null: false
    t.string "nonce", null: false
    t.datetime "expires_at", precision: nil, null: false
    t.integer "request_object_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "pairwise_pseudonymous_identifiers", id: :serial, force: :cascade do |t|
    t.integer "fake_user_id", null: false
    t.string "identifier", null: false
    t.string "sector_identifier", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["identifier"], name: "index_pairwise_pseudonymous_identifiers_on_identifier", unique: true
  end

  create_table "request_objects", force: :cascade do |t|
    t.text "request_parameters", null: false, comment: "JSONテキスト"
    t.datetime "expires_at", precision: nil, comment: "PAR の場合のみ"
    t.string "reference_value", comment: "PAR の場合のみ。`urn:ietf:params:oauth:request_uri:` に続ける"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reference_value"], name: "index_request_objects_on_reference_value", unique: true
  end

  create_table "scopes", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["name"], name: "index_scopes_on_name", unique: true
  end

  add_foreign_key "access_token_scopes", "access_tokens"
  add_foreign_key "access_token_scopes", "scopes"
  add_foreign_key "access_tokens", "clients"
  add_foreign_key "access_tokens", "fake_users"
  add_foreign_key "access_tokens", "request_objects"
  add_foreign_key "authorization_scopes", "authorizations"
  add_foreign_key "authorization_scopes", "scopes"
  add_foreign_key "authorizations", "clients"
  add_foreign_key "authorizations", "fake_users"
  add_foreign_key "authorizations", "request_objects"
  add_foreign_key "clients", "accounts"
  add_foreign_key "connect_google", "accounts"
  add_foreign_key "id_tokens", "clients"
  add_foreign_key "id_tokens", "fake_users"
  add_foreign_key "id_tokens", "request_objects"
  add_foreign_key "pairwise_pseudonymous_identifiers", "fake_users"
end

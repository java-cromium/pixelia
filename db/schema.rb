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

ActiveRecord::Schema[8.0].define(version: 2026_06_01_173100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "industry"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_customer_id"
    t.string "plan", default: "free", null: false
    t.string "subscription_status", default: "trialing", null: false
    t.datetime "trial_ends_at"
    t.index ["plan"], name: "index_accounts_on_plan"
    t.index ["stripe_customer_id"], name: "index_accounts_on_stripe_customer_id", unique: true
  end

  create_table "chat_conversations", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "user_id", null: false
    t.string "title", default: "New conversation"
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "updated_at"], name: "index_chat_conversations_on_account_id_and_updated_at"
    t.index ["account_id"], name: "index_chat_conversations_on_account_id"
    t.index ["user_id"], name: "index_chat_conversations_on_user_id"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.bigint "chat_conversation_id", null: false
    t.string "role", null: false
    t.text "content", null: false
    t.integer "tokens_used"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_conversation_id"], name: "index_chat_messages_on_chat_conversation_id"
  end

  create_table "ecommerce_stores", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "platform"
    t.string "store_url"
    t.string "api_key"
    t.string "api_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_ecommerce_stores_on_account_id"
  end

  create_table "google_ad_accounts", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "google_customer_id"
    t.string "google_email"
    t.text "access_token"
    t.text "refresh_token"
    t.datetime "token_expires_at"
    t.string "status", default: "connected", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_google_ad_accounts_on_account_id", unique: true
    t.index ["google_customer_id"], name: "index_google_ad_accounts_on_google_customer_id"
  end

  create_table "google_ad_campaigns", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "google_ad_account_id", null: false
    t.string "google_campaign_id"
    t.string "name"
    t.string "campaign_type"
    t.string "status"
    t.bigint "budget_amount_micros"
    t.string "target_url"
    t.date "start_date"
    t.date "end_date"
    t.jsonb "settings"
    t.datetime "last_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "status"], name: "index_google_ad_campaigns_on_account_id_and_status"
    t.index ["account_id"], name: "index_google_ad_campaigns_on_account_id"
    t.index ["google_ad_account_id"], name: "index_google_ad_campaigns_on_google_ad_account_id"
    t.index ["google_campaign_id"], name: "index_google_ad_campaigns_on_google_campaign_id", unique: true
  end

  create_table "leads", force: :cascade do |t|
    t.string "first_name"
    t.string "email"
    t.string "project_type"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meta_ad_accounts", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "meta_business_id"
    t.string "meta_ad_account_id"
    t.string "meta_email"
    t.text "access_token"
    t.datetime "token_expires_at"
    t.string "status", default: "connected", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_meta_ad_accounts_on_account_id", unique: true
  end

  create_table "meta_ad_campaigns", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "meta_ad_account_id", null: false
    t.string "meta_campaign_id"
    t.string "name", null: false
    t.string "objective", default: "OUTCOME_TRAFFIC", null: false
    t.string "status", default: "draft", null: false
    t.bigint "daily_budget_cents"
    t.bigint "lifetime_budget_cents"
    t.string "target_url"
    t.date "start_date"
    t.date "end_date"
    t.jsonb "settings", default: {}
    t.datetime "last_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "status"], name: "index_meta_ad_campaigns_on_account_id_and_status"
    t.index ["account_id"], name: "index_meta_ad_campaigns_on_account_id"
    t.index ["meta_ad_account_id"], name: "index_meta_ad_campaigns_on_meta_ad_account_id"
    t.index ["meta_campaign_id"], name: "index_meta_ad_campaigns_on_meta_campaign_id"
  end

  create_table "pages", force: :cascade do |t|
    t.bigint "site_id", null: false
    t.string "title", null: false
    t.string "slug", null: false
    t.jsonb "content", default: {}
    t.text "html_content"
    t.text "css_content"
    t.string "status", default: "draft", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id", "slug"], name: "index_pages_on_site_id_and_slug", unique: true
    t.index ["site_id"], name: "index_pages_on_site_id"
  end

  create_table "pay_charges", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "subscription_id"
    t.string "processor_id", null: false
    t.integer "amount", null: false
    t.string "currency"
    t.integer "application_fee_amount"
    t.integer "amount_refunded"
    t.jsonb "metadata"
    t.jsonb "data"
    t.string "stripe_account"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_charges_on_customer_id_and_processor_id", unique: true
    t.index ["subscription_id"], name: "index_pay_charges_on_subscription_id"
  end

  create_table "pay_customers", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "processor", null: false
    t.string "processor_id"
    t.boolean "default"
    t.jsonb "data"
    t.string "stripe_account"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "deleted_at"], name: "pay_customer_owner_index", unique: true
    t.index ["processor", "processor_id"], name: "index_pay_customers_on_processor_and_processor_id", unique: true
  end

  create_table "pay_merchants", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "processor", null: false
    t.string "processor_id"
    t.boolean "default"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "processor"], name: "index_pay_merchants_on_owner_type_and_owner_id_and_processor"
  end

  create_table "pay_payment_methods", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "processor_id", null: false
    t.boolean "default"
    t.string "type"
    t.jsonb "data"
    t.string "stripe_account"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_payment_methods_on_customer_id_and_processor_id", unique: true
  end

  create_table "pay_subscriptions", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "name", null: false
    t.string "processor_id", null: false
    t.string "processor_plan", null: false
    t.integer "quantity", default: 1, null: false
    t.string "status", null: false
    t.datetime "current_period_start", precision: nil
    t.datetime "current_period_end", precision: nil
    t.datetime "trial_ends_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.boolean "metered"
    t.string "pause_behavior"
    t.datetime "pause_starts_at", precision: nil
    t.datetime "pause_resumes_at", precision: nil
    t.decimal "application_fee_percent", precision: 8, scale: 2
    t.jsonb "metadata"
    t.jsonb "data"
    t.string "stripe_account"
    t.string "payment_method_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_subscriptions_on_customer_id_and_processor_id", unique: true
    t.index ["metered"], name: "index_pay_subscriptions_on_metered"
    t.index ["pause_starts_at"], name: "index_pay_subscriptions_on_pause_starts_at"
  end

  create_table "pay_webhooks", force: :cascade do |t|
    t.string "processor"
    t.string "event_type"
    t.jsonb "event"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sites", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "name", null: false
    t.string "subdomain"
    t.string "custom_domain"
    t.jsonb "theme_config", default: {}
    t.boolean "published", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cf_hostname_id"
    t.string "domain_status"
    t.string "ssl_status"
    t.string "domain_verification_token"
    t.jsonb "domain_verification_errors", default: []
    t.index ["account_id"], name: "index_sites_on_account_id"
    t.index ["cf_hostname_id"], name: "index_sites_on_cf_hostname_id", unique: true
    t.index ["custom_domain"], name: "index_sites_on_custom_domain", unique: true
    t.index ["domain_status"], name: "index_sites_on_domain_status"
    t.index ["subdomain"], name: "index_sites_on_subdomain", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "onboarding_completed_at"
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chat_conversations", "accounts"
  add_foreign_key "chat_conversations", "users"
  add_foreign_key "chat_messages", "chat_conversations"
  add_foreign_key "ecommerce_stores", "accounts"
  add_foreign_key "google_ad_accounts", "accounts"
  add_foreign_key "google_ad_campaigns", "accounts"
  add_foreign_key "google_ad_campaigns", "google_ad_accounts"
  add_foreign_key "meta_ad_accounts", "accounts"
  add_foreign_key "meta_ad_campaigns", "accounts"
  add_foreign_key "meta_ad_campaigns", "meta_ad_accounts"
  add_foreign_key "pages", "sites"
  add_foreign_key "pay_charges", "pay_customers", column: "customer_id"
  add_foreign_key "pay_charges", "pay_subscriptions", column: "subscription_id"
  add_foreign_key "pay_payment_methods", "pay_customers", column: "customer_id"
  add_foreign_key "pay_subscriptions", "pay_customers", column: "customer_id"
  add_foreign_key "sites", "accounts"
  add_foreign_key "users", "accounts"
end

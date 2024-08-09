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

ActiveRecord::Schema[7.1].define(version: 2024_08_09_172000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "project_article_feature_status", ["error", "skipped", "wait", "processing", "completed", "static"]
  create_enum "project_llm_call_service_name", ["summary", "products", "default"]
  create_enum "user_locale", ["en", "es"]
  create_enum "user_project_llm", ["gpt-3.5-turbo", "gpt-4o", "gpt-4o-mini"]
  create_enum "user_project_protocol", ["http", "https"]
  create_enum "user_project_status", ["active", "suspended", "deleted"]
  create_enum "user_project_type", ["free", "light", "pro"]

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "project_id"
    t.string "category", null: false
    t.string "subcategory", null: false
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.string "source"
    t.jsonb "details", default: {}, null: false
    t.string "author_type"
    t.bigint "author_id"
    t.index ["author_type", "author_id"], name: "index_events_on_author"
    t.index ["created_at"], name: "index_events_on_created_at"
    t.index ["project_id", "source"], name: "index_events_on_project_id_and_source"
    t.index ["source"], name: "index_events_on_source"
    t.index ["trackable_type", "trackable_id"], name: "index_events_on_trackable"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "project_article_products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "project_article_id", null: false
    t.bigint "project_product_id", null: false
    t.index ["project_article_id", "project_product_id"], name: "idx_on_project_article_id_project_product_id_4f7270e242", unique: true
    t.index ["project_article_id"], name: "index_project_article_products_on_project_article_id"
    t.index ["project_product_id"], name: "index_project_article_products_on_project_product_id"
  end

  create_table "project_articles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_id", null: false
    t.string "article_hash", null: false
    t.text "title"
    t.text "article", null: false
    t.integer "tokens_count", default: 0, null: false
    t.text "image_url"
    t.datetime "last_modified_at"
    t.datetime "last_scraped_at"
    t.jsonb "info", default: {}, null: false
    t.enum "summary_status", default: "wait", null: false, enum_type: "project_article_feature_status"
    t.bigint "summary_llm_call_id"
    t.enum "products_status", default: "wait", null: false, enum_type: "project_article_feature_status"
    t.bigint "products_llm_call_id"
    t.index ["products_llm_call_id"], name: "index_project_articles_on_products_llm_call_id"
    t.index ["project_id", "article_hash"], name: "index_project_articles_on_project_id_and_article_hash", unique: true
    t.index ["project_id"], name: "index_project_articles_on_project_id"
    t.index ["summary_llm_call_id"], name: "index_project_articles_on_summary_llm_call_id"
  end

  create_table "project_llm_calls", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_id", null: false
    t.string "initializer_type"
    t.bigint "initializer_id"
    t.enum "feature", default: "default", null: false, enum_type: "project_llm_call_service_name"
    t.jsonb "info", default: {}, null: false
    t.integer "in_tokens_count", default: 0, null: false
    t.text "input"
    t.enum "llm", null: false, enum_type: "user_project_llm"
    t.integer "out_tokens_count", default: 0, null: false
    t.text "output"
    t.index ["initializer_type", "initializer_id", "feature"], name: "idx_on_initializer_type_initializer_id_feature_f0de9640c3"
    t.index ["initializer_type", "initializer_id"], name: "index_project_llm_calls_on_initializer"
    t.index ["project_id"], name: "index_project_llm_calls_on_project_id"
  end

  create_table "project_pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_id", null: false
    t.string "url_hash", null: false
    t.string "url", null: false
    t.boolean "is_accessible", default: true, null: false
    t.bigint "project_article_id", null: false
    t.index ["project_article_id"], name: "index_project_pages_on_project_article_id"
    t.index ["project_id", "url"], name: "index_project_pages_on_project_id_and_url", unique: true
    t.index ["project_id", "url_hash"], name: "index_project_pages_on_project_id_and_url_hash", unique: true
    t.index ["project_id"], name: "index_project_pages_on_project_id"
  end

  create_table "project_products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_id", null: false
    t.string "name", null: false
    t.string "description", null: false
    t.string "link", null: false
    t.jsonb "info"
    t.binary "icon"
    t.boolean "is_accessible", default: true, null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["project_id", "uuid"], name: "index_project_products_on_project_id_and_uuid"
    t.index ["project_id"], name: "index_project_products_on_project_id"
    t.index ["uuid"], name: "index_project_products_on_uuid", unique: true
  end

  create_table "project_statistics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.bigint "project_id", null: false
    t.date "date", null: false
    t.integer "hour", limit: 2, null: false
    t.bigint "views", default: 0, null: false
    t.bigint "clicks", default: 0, null: false
    t.index ["project_id", "date"], name: "index_project_statistics_on_project_id_and_date"
    t.index ["project_id", "trackable_type", "trackable_id", "date", "hour"], name: "idx_on_project_id_trackable_type_trackable_id_date__92da09a367", unique: true
    t.index ["project_id"], name: "index_project_statistics_on_project_id"
    t.index ["trackable_type", "trackable_id"], name: "index_project_statistics_on_trackable"
  end

  create_table "project_user_emails", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_id", null: false
    t.bigint "project_page_id", null: false
    t.string "email", null: false
    t.string "encrypted_page_id", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["encrypted_page_id"], name: "index_project_user_emails_on_encrypted_page_id", unique: true
    t.index ["project_id", "email"], name: "index_project_user_emails_on_project_id_and_email", unique: true
    t.index ["uuid"], name: "index_project_user_emails_on_uuid", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "user_id", null: false
    t.string "name", default: "", null: false
    t.string "protocol", null: false
    t.string "domain", null: false
    t.jsonb "paths", default: [], null: false
    t.jsonb "settings", default: {}, null: false
    t.enum "status", default: "active", null: false, enum_type: "user_project_status"
    t.datetime "deleted_at"
    t.enum "plan", default: "free", null: false, enum_type: "user_project_type"
    t.enum "default_llm", default: "gpt-4o-mini", null: false, enum_type: "user_project_llm"
    t.text "guidelines", default: ""
    t.jsonb "stripe", default: {}, null: false
    t.integer "free_clicks_threshold", default: 500, null: false
    t.index ["created_at"], name: "index_projects_on_created_at"
    t.index ["user_id", "domain"], name: "index_projects_on_user_id_and_domain", unique: true, where: "(status <> 'deleted'::user_project_status)"
    t.index ["user_id", "name"], name: "index_projects_on_user_id_and_name", unique: true, where: "(status <> 'deleted'::user_project_status)"
    t.index ["user_id"], name: "index_projects_on_user_id"
    t.index ["uuid"], name: "index_projects_on_uuid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.text "avatar_url"
    t.enum "locale", default: "en", null: false, enum_type: "user_locale"
    t.boolean "is_admin", default: false, null: false
    t.datetime "deleted_at"
    t.bigint "default_project_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["default_project_id"], name: "index_users_on_default_project_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "events", "projects", on_update: :cascade, on_delete: :cascade
  add_foreign_key "project_article_products", "project_articles", on_update: :cascade, on_delete: :cascade
  add_foreign_key "project_article_products", "project_products", on_update: :cascade, on_delete: :cascade
  add_foreign_key "project_articles", "project_llm_calls", column: "products_llm_call_id"
  add_foreign_key "project_articles", "project_llm_calls", column: "summary_llm_call_id"
  add_foreign_key "project_articles", "projects"
  add_foreign_key "project_llm_calls", "projects", on_update: :cascade, on_delete: :cascade
  add_foreign_key "project_pages", "project_articles", on_update: :cascade
  add_foreign_key "project_pages", "projects", on_update: :cascade
  add_foreign_key "project_products", "projects", on_update: :cascade, on_delete: :cascade
  add_foreign_key "project_statistics", "projects", on_update: :cascade
  add_foreign_key "project_user_emails", "project_pages", on_update: :cascade, on_delete: :cascade
  add_foreign_key "project_user_emails", "projects", on_update: :cascade, on_delete: :cascade
  add_foreign_key "projects", "users", on_update: :cascade
  add_foreign_key "users", "projects", column: "default_project_id", on_update: :cascade, on_delete: :nullify

  create_view "project_statistics_by_totals", sql_definition: <<-SQL
      SELECT ps.project_id,
      ps.trackable_type,
      ps.trackable_id,
      (sum(ps.clicks))::bigint AS clicks,
      (sum(ps.views))::bigint AS views
     FROM project_statistics ps
    GROUP BY ps.project_id, ps.trackable_type, ps.trackable_id;
  SQL
end

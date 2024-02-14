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

ActiveRecord::Schema[7.1].define(version: 2024_02_03_115500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "project_article_status", ["in_queue", "processing", "summarized", "error", "skipped"]
  create_enum "user_locale", ["en", "es"]
  create_enum "user_project_llm", ["gpt3.5", "gpt4"]
  create_enum "user_project_status", ["active", "suspended", "deleted"]
  create_enum "user_project_type", ["free", "paid"]

  create_table "events", force: :cascade do |t|
    t.string "category", null: false
    t.string "subcategory", null: false
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.string "source"
    t.jsonb "details", null: false
    t.string "author_type"
    t.bigint "author_id"
    t.bigint "project_id"
    t.datetime "created_at", null: false
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

  create_table "project_article_statistics", force: :cascade do |t|
    t.bigint "project_article_id", null: false
    t.bigint "project_url_id", null: false
    t.date "date", null: false
    t.integer "hour", limit: 2, null: false
    t.bigint "views", default: 0, null: false
    t.bigint "clicks", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_project_article_statistics_on_date"
    t.index ["project_article_id", "project_url_id", "date", "hour"], name: "idx_on_project_article_id_project_url_id_date_hour_aee771512a", unique: true
    t.index ["project_article_id"], name: "index_project_article_statistics_on_project_article_id"
    t.index ["project_url_id"], name: "index_project_article_statistics_on_project_url_id"
  end

  create_table "project_articles", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "article_hash", null: false
    t.text "title"
    t.text "article", null: false
    t.enum "status", default: "in_queue", null: false, enum_type: "project_article_status"
    t.integer "tokens_in_count", default: 0, null: false
    t.integer "tokens_out_count", default: 0, null: false
    t.enum "llm", enum_type: "user_project_llm"
    t.jsonb "service_info"
    t.text "image_url"
    t.datetime "last_modified_at"
    t.datetime "last_scraped_at"
    t.text "summary"
    t.datetime "summarized_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "article_hash"], name: "index_project_articles_on_project_id_and_article_hash", unique: true
    t.index ["project_id"], name: "index_project_articles_on_project_id"
  end

  create_table "project_urls", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "url_hash", null: false
    t.string "url", null: false
    t.boolean "is_accessible", default: true, null: false
    t.bigint "project_article_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_article_id"], name: "index_project_urls_on_project_article_id"
    t.index ["project_id", "url_hash"], name: "index_project_urls_on_project_id_and_url_hash", unique: true
    t.index ["project_id"], name: "index_project_urls_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "user_id", null: false
    t.string "name", default: "", null: false
    t.string "domain", null: false
    t.enum "plan", default: "free", null: false, enum_type: "user_project_type"
    t.enum "status", default: "active", null: false, enum_type: "user_project_status"
    t.jsonb "settings"
    t.enum "default_llm", default: "gpt3.5", null: false, enum_type: "user_project_llm"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["created_at"], name: "index_projects_on_created_at"
    t.index ["user_id", "domain"], name: "index_projects_on_user_id_and_domain", unique: true
    t.index ["user_id", "name"], name: "index_projects_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_projects_on_user_id"
    t.index ["uuid"], name: "index_projects_on_uuid", unique: true
  end

  create_table "users", force: :cascade do |t|
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  add_foreign_key "project_article_statistics", "project_articles", on_update: :cascade
  add_foreign_key "project_article_statistics", "project_urls", on_update: :cascade
  add_foreign_key "project_articles", "projects"
  add_foreign_key "project_urls", "project_articles", on_update: :cascade
  add_foreign_key "project_urls", "projects", on_update: :cascade
  add_foreign_key "projects", "users", on_update: :cascade
  add_foreign_key "users", "projects", column: "default_project_id", on_update: :cascade, on_delete: :nullify
end

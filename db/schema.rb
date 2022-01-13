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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_01_04_123603) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "account_compliance_stats", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "account_id", null: false
    t.integer "document_compliance_percentage", null: false
    t.integer "training_compliance_percentage", null: false
    t.index ["account_id"], name: "index_account_compliance_stats_on_account_id", unique: true
  end

  create_table "accounts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.datetime "deactivated_at"
    t.string "invite_token", limit: 128
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id"
    t.boolean "time_tracking", default: false, null: false
    t.boolean "is_calculating_compliance_stats", default: false, null: false
    t.datetime "compliance_stats_last_updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.boolean "two_factor_enabled", default: false, null: false
    t.index ["name"], name: "index_accounts_on_name", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "assigned_tracks", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "track_id", null: false
    t.uuid "employee_record_id", null: false
    t.index ["employee_record_id", "track_id"], name: "index_assigned_tracks_on_employee_record_id_and_track_id", unique: true
    t.index ["employee_record_id"], name: "index_assigned_tracks_on_employee_record_id"
    t.index ["track_id", "employee_record_id"], name: "index_assigned_tracks_on_track_id_and_employee_record_id"
    t.index ["track_id"], name: "index_assigned_tracks_on_track_id"
  end

  create_table "assignments", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "course_id", null: false
    t.uuid "employee_record_id", null: false
    t.index ["course_id", "employee_record_id"], name: "index_assignments_on_course_id_and_employee_record_id"
    t.index ["course_id"], name: "index_assignments_on_course_id"
    t.index ["employee_record_id", "course_id"], name: "index_assignments_on_employee_record_id_and_course_id", unique: true
    t.index ["employee_record_id"], name: "index_assignments_on_employee_record_id"
  end

  create_table "certificates", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "passed_on", null: false
    t.date "expires_on"
    t.uuid "employee_record_id"
    t.uuid "course_id"
    t.index ["course_id"], name: "index_certificates_on_course_id"
    t.index ["employee_record_id"], name: "index_certificates_on_employee_record_id"
  end

  create_table "choices", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "question_id", null: false
    t.string "answer", null: false
    t.boolean "is_correct", default: false, null: false
    t.index ["question_id"], name: "index_choices_on_question_id"
  end

  create_table "contact_documents", force: :cascade do |t|
    t.string "file_name"
    t.string "file_path"
    t.uuid "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_contact_documents_on_contact_id"
  end

  create_table "contact_notes", force: :cascade do |t|
    t.text "note"
    t.uuid "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_contact_notes_on_contact_id"
  end

  create_table "contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_email", null: false
    t.string "contact_address", null: false
    t.string "contact_number_1", null: false
    t.string "contact_number_2"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.uuid "office_id"
    t.index ["office_id"], name: "index_contacts_on_office_id"
  end

  create_table "courses", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "account_id"
    t.citext "title", null: false
    t.string "code"
    t.string "description"
    t.integer "compliance_expiration_in_days", default: 0, null: false
    t.integer "max_test_retakes", null: false
    t.integer "passing_threshold_percentage", null: false
    t.datetime "deactivated_at"
    t.string "material_url"
    t.string "material_s3_key"
    t.string "states", default: [], array: true
    t.string "supplements", default: [], array: true
    t.integer "days_due_within"
    t.integer "certificate_type", default: 1, null: false
    t.index ["account_id"], name: "index_courses_on_account_id"
    t.index ["states"], name: "index_courses_on_states", using: :gin
    t.index ["title", "account_id"], name: "index_courses_on_title_and_account_id", unique: true
  end

  create_table "courses_tracks", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "track_id", null: false
    t.uuid "course_id", null: false
    t.integer "position"
    t.index ["course_id"], name: "index_courses_tracks_on_course_id"
    t.index ["track_id", "course_id"], name: "index_courses_tracks_on_track_id_and_course_id", unique: true
    t.index ["track_id"], name: "index_courses_tracks_on_track_id"
  end

  create_table "document_group_presets", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.citext "name", null: false
    t.jsonb "document_types", default: [], null: false
    t.boolean "is_default", default: false, null: false
    t.string "applies_to", default: "employees", null: false
    t.index ["name"], name: "index_document_group_presets_on_name"
  end

  create_table "document_groups", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.citext "name", null: false
    t.uuid "account_id", null: false
    t.string "applies_to", default: "employees", null: false
    t.index ["account_id"], name: "index_document_groups_on_account_id"
    t.index ["name", "account_id"], name: "index_document_groups_on_name_and_account_id", unique: true
    t.index ["name"], name: "index_document_groups_on_name"
  end

  create_table "document_types", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.citext "name", null: false
    t.uuid "account_id"
    t.boolean "is_confidential", default: false, null: false
    t.string "applies_to", default: "employees", null: false
    t.index ["account_id"], name: "index_document_types_on_account_id"
    t.index ["name", "account_id", "applies_to"], name: "index_document_types_on_name_and_account_id_and_applies_to", unique: true
    t.index ["name"], name: "index_document_types_on_name"
  end

  create_table "document_types_groupings", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "document_type_id", null: false
    t.uuid "document_group_id", null: false
    t.boolean "required", default: false, null: false
    t.index ["document_group_id"], name: "index_document_types_groupings_on_document_group_id"
    t.index ["document_type_id"], name: "index_document_types_groupings_on_document_type_id"
  end

  create_table "documents", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "deprecated_employee_record_id"
    t.uuid "document_type_id", null: false
    t.datetime "expires_on"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.string "summary"
    t.index ["deprecated_employee_record_id"], name: "index_documents_on_deprecated_employee_record_id"
    t.index ["document_type_id"], name: "index_documents_on_document_type_id"
  end

  create_table "employee_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "employee_record_id", null: false
    t.uuid "document_id", null: false
    t.index ["document_id"], name: "index_employee_documents_on_document_id"
    t.index ["employee_record_id"], name: "index_employee_documents_on_employee_record_id"
  end

  create_table "employee_notes", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "employee_record_id", null: false
    t.uuid "creator_id", null: false
    t.string "body", null: false
    t.index ["creator_id"], name: "index_employee_notes_on_creator_id"
    t.index ["employee_record_id"], name: "index_employee_notes_on_employee_record_id"
  end

  create_table "employee_records", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "office_id", null: false
    t.citext "title"
    t.integer "employment_type", null: false
    t.integer "status", default: 1, null: false
    t.integer "marital_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.citext "first_name", null: false
    t.citext "last_name", null: false
    t.uuid "user_id"
    t.string "encrypted_dob"
    t.string "encrypted_phone"
    t.string "encrypted_emergency_contact_name"
    t.string "encrypted_emergency_contact_relationship"
    t.string "encrypted_emergency_contact_phone"
    t.string "encrypted_emergency_contact_email"
    t.string "encrypted_dob_iv"
    t.string "encrypted_phone_iv"
    t.string "encrypted_emergency_contact_name_iv"
    t.string "encrypted_emergency_contact_relationship_iv"
    t.string "encrypted_emergency_contact_phone_iv"
    t.string "encrypted_emergency_contact_email_iv"
    t.datetime "terminated_on"
    t.datetime "hired_on"
    t.string "encrypted_address"
    t.string "encrypted_address_iv"
    t.uuid "document_group_id", null: false
    t.string "agd_member_number"
    t.index ["document_group_id"], name: "index_employee_records_on_document_group_id"
    t.index ["office_id"], name: "index_employee_records_on_office_id"
    t.index ["user_id"], name: "index_employee_records_on_user_id", unique: true
  end

  create_table "exams", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "assignment_id"
    t.boolean "passed", null: false
    t.index ["assignment_id"], name: "index_exams_on_assignment_id"
  end

  create_table "expired_documents", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "employee_record_id"
    t.uuid "document_type_id"
    t.index ["document_type_id"], name: "index_expired_documents_on_document_type_id"
    t.index ["employee_record_id"], name: "index_expired_documents_on_employee_record_id"
  end

  create_table "expiring_documents", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "employee_record_id"
    t.uuid "document_type_id"
    t.integer "days_until_expiry", null: false
    t.index ["document_type_id"], name: "index_expiring_documents_on_document_type_id"
    t.index ["employee_record_id"], name: "index_expiring_documents_on_employee_record_id"
  end

  create_table "incomplete_assignments", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "assignment_id"
    t.string "status"
    t.date "due_date"
    t.index ["assignment_id"], name: "index_incomplete_assignments_on_assignment_id"
  end

  create_table "library_documents", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "account_id"
    t.citext "name", null: false
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.string "summary"
    t.boolean "is_visible_to_employees", default: false, null: false
    t.index ["account_id"], name: "index_library_documents_on_account_id"
    t.index ["name", "account_id"], name: "index_library_documents_on_name_and_account_id", unique: true
  end

  create_table "missing_documents", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "employee_record_id"
    t.uuid "document_type_id"
    t.index ["document_type_id"], name: "index_missing_documents_on_document_type_id"
    t.index ["employee_record_id"], name: "index_missing_documents_on_employee_record_id"
  end

  create_table "office_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "office_id", null: false
    t.uuid "document_id", null: false
    t.index ["document_id"], name: "index_office_documents_on_document_id"
    t.index ["office_id"], name: "index_office_documents_on_office_id"
  end

  create_table "offices", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.citext "name", null: false
    t.citext "street_address", null: false
    t.citext "address2"
    t.citext "city", null: false
    t.citext "state", null: false
    t.string "zip", null: false
    t.string "phone", null: false
    t.uuid "account_id"
    t.string "time_zone", default: "Central Time (US & Canada)", null: false
    t.boolean "tracks_time", default: false, null: false
    t.integer "document_compliance_percentage", default: 0, null: false
    t.integer "training_compliance_percentage", default: 0, null: false
    t.uuid "document_group_id", null: false
    t.index ["account_id"], name: "index_offices_on_account_id"
    t.index ["document_group_id"], name: "index_offices_on_document_group_id"
    t.index ["name", "account_id"], name: "index_offices_on_name_and_account_id", unique: true
  end

  create_table "offices_users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "office_id", null: false
    t.uuid "user_id", null: false
    t.index ["office_id", "user_id"], name: "index_offices_users_on_office_id_and_user_id", unique: true
    t.index ["office_id"], name: "index_offices_users_on_office_id"
    t.index ["user_id"], name: "index_offices_users_on_user_id"
  end

  create_table "plans", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "account_id"
    t.integer "monthly_price", null: false
    t.integer "max_employees", null: false
    t.index ["account_id"], name: "index_plans_on_account_id", unique: true
  end

  create_table "pto_entries", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "employee_record_id", null: false
    t.decimal "hours", default: "0.0", null: false
    t.date "date", null: false
    t.index ["employee_record_id", "date"], name: "index_pto_entries_on_employee_record_id_and_date", unique: true
    t.index ["employee_record_id"], name: "index_pto_entries_on_employee_record_id"
  end

  create_table "questions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "course_id", null: false
    t.string "text", null: false
    t.index ["course_id"], name: "index_questions_on_course_id"
  end

  create_table "task_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "file_name"
    t.string "file_path"
    t.uuid "task_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_task_documents_on_task_id"
  end

  create_table "tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.date "due_date", null: false
    t.date "expiry_date", null: false
    t.date "submitted_date"
    t.text "submit_note"
    t.string "status", null: false
    t.integer "created_user", null: false
    t.integer "assigned_user", null: false
    t.uuid "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_tasks_on_account_id"
  end

  create_table "time_entries", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "employee_record_id", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "entry_type", default: 0, null: false
    t.index ["employee_record_id"], name: "index_time_entries_on_employee_record_id"
    t.index ["occurred_at"], name: "index_time_entries_on_occurred_at"
  end

  create_table "track_presets", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.citext "name"
    t.jsonb "courses", default: [], null: false
    t.index ["name"], name: "index_track_presets_on_name", unique: true
  end

  create_table "tracks", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "account_id", null: false
    t.string "name", null: false
    t.datetime "deactivated_at"
    t.index ["account_id"], name: "index_tracks_on_account_id"
    t.index ["name", "account_id"], name: "index_tracks_on_name_and_account_id", unique: true
  end

  create_table "users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.citext "first_name", null: false
    t.citext "last_name", null: false
    t.citext "email", null: false
    t.string "encrypted_password", limit: 128
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128
    t.uuid "account_id"
    t.integer "role", null: false
    t.jsonb "settings", default: {}, null: false
    t.jsonb "chat_terms"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.inet "last_sign_in_ip"
    t.boolean "two_factor_enabled"
    t.datetime "two_factor_setup_at"
    t.string "encrypted_otp_secret_key"
    t.string "encrypted_otp_secret_key_iv"
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  add_foreign_key "account_compliance_stats", "accounts"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assigned_tracks", "employee_records", on_delete: :cascade
  add_foreign_key "assigned_tracks", "tracks", on_delete: :cascade
  add_foreign_key "assignments", "courses"
  add_foreign_key "assignments", "employee_records"
  add_foreign_key "certificates", "courses"
  add_foreign_key "certificates", "employee_records"
  add_foreign_key "choices", "questions"
  add_foreign_key "contact_documents", "contacts"
  add_foreign_key "contact_notes", "contacts"
  add_foreign_key "contacts", "offices"
  add_foreign_key "courses", "accounts"
  add_foreign_key "courses_tracks", "courses", on_delete: :cascade
  add_foreign_key "courses_tracks", "tracks", on_delete: :cascade
  add_foreign_key "document_groups", "accounts", on_delete: :cascade
  add_foreign_key "document_types", "accounts"
  add_foreign_key "document_types_groupings", "document_groups", on_delete: :cascade
  add_foreign_key "document_types_groupings", "document_types", on_delete: :cascade
  add_foreign_key "documents", "document_types"
  add_foreign_key "documents", "employee_records", column: "deprecated_employee_record_id"
  add_foreign_key "employee_documents", "documents", on_delete: :cascade
  add_foreign_key "employee_documents", "employee_records", on_delete: :cascade
  add_foreign_key "employee_notes", "employee_records", on_delete: :cascade
  add_foreign_key "employee_notes", "users", column: "creator_id"
  add_foreign_key "employee_records", "document_groups"
  add_foreign_key "employee_records", "offices"
  add_foreign_key "employee_records", "users", on_delete: :nullify
  add_foreign_key "exams", "assignments"
  add_foreign_key "expired_documents", "document_types", on_delete: :cascade
  add_foreign_key "expired_documents", "employee_records", on_delete: :cascade
  add_foreign_key "expiring_documents", "document_types", on_delete: :cascade
  add_foreign_key "expiring_documents", "employee_records", on_delete: :cascade
  add_foreign_key "incomplete_assignments", "assignments", on_delete: :cascade
  add_foreign_key "library_documents", "accounts"
  add_foreign_key "missing_documents", "document_types", on_delete: :cascade
  add_foreign_key "missing_documents", "employee_records", on_delete: :cascade
  add_foreign_key "office_documents", "documents", on_delete: :cascade
  add_foreign_key "office_documents", "offices", on_delete: :cascade
  add_foreign_key "offices", "accounts"
  add_foreign_key "offices", "document_groups"
  add_foreign_key "offices_users", "offices", on_delete: :cascade
  add_foreign_key "offices_users", "users", on_delete: :cascade
  add_foreign_key "plans", "accounts"
  add_foreign_key "pto_entries", "employee_records"
  add_foreign_key "questions", "courses"
  add_foreign_key "task_documents", "tasks"
  add_foreign_key "tasks", "accounts"
  add_foreign_key "time_entries", "employee_records"
  add_foreign_key "tracks", "accounts"
  add_foreign_key "users", "accounts"
end

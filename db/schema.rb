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

ActiveRecord::Schema[7.2].define(version: 2024_08_27_204529) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "vulnerabilities", force: :cascade do |t|
    t.string "os"
    t.string "object_hash"
    t.string "name"
    t.string "cve_id"
    t.string "target"
    t.string "service"
    t.string "evidence"
    t.string "severity"
    t.text "solution"
    t.string "scan_name"
    t.string "cvss_score"
    t.string "ip_address"
    t.string "pci_status"
    t.string "target_tag"
    t.text "description"
    t.string "host_status"
    t.string "project_name"
    t.string "discovered_date"
    t.string "last_scanned_date"
    t.string "service_description"
    t.string "approved_false_positive_evidence"
    t.integer "status", default: 0
    t.bigint "vulnerability_scan_id"
    t.bigint "admin_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_vulnerabilities_on_admin_user_id"
    t.index ["vulnerability_scan_id"], name: "index_vulnerabilities_on_vulnerability_scan_id"
  end

  create_table "vulnerabilities_vulnerability_scans", id: false, force: :cascade do |t|
    t.bigint "vulnerability_scan_id"
    t.bigint "vulnerability_id"
    t.index ["vulnerability_id"], name: "index_vulnerabilities_vulnerability_scans_on_vulnerability_id"
    t.index ["vulnerability_scan_id"], name: "idx_on_vulnerability_scan_id_e91cf184d3"
  end

  create_table "vulnerability_scans", force: :cascade do |t|
    t.string "name"
    t.bigint "vulnerability_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vulnerability_id"], name: "index_vulnerability_scans_on_vulnerability_id"
  end

  create_table "vulnerability_updates", force: :cascade do |t|
    t.bigint "vulnerability_scan_id", null: false
    t.bigint "vulnerability_id", null: false
    t.integer "update_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vulnerability_id"], name: "index_vulnerability_updates_on_vulnerability_id"
    t.index ["vulnerability_scan_id"], name: "index_vulnerability_updates_on_vulnerability_scan_id"
  end

  add_foreign_key "vulnerability_updates", "vulnerabilities"
  add_foreign_key "vulnerability_updates", "vulnerability_scans"
end

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

ActiveRecord::Schema.define(version: 2021_08_13_074812) do

  create_table "conversation_members", force: :cascade do |t|
    t.integer "member_id", null: false
    t.integer "conversation_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["conversation_id"], name: "index_conversation_members_on_conversation_id"
    t.index ["member_id"], name: "index_conversation_members_on_member_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.string "conversation_id"
    t.string "conversation_user_id"
    t.boolean "is_archived"
    t.boolean "is_user_deleted"
    t.boolean "is_channel"
    t.boolean "is_group"
    t.boolean "is_member"
    t.boolean "is_private"
    t.string "name"
    t.string "creator_id"
    t.string "last_read"
    t.integer "team_id", null: false
    t.integer "slack_user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slack_user_id"], name: "index_conversations_on_slack_user_id"
    t.index ["team_id"], name: "index_conversations_on_team_id"
  end

  create_table "members", force: :cascade do |t|
    t.string "member_id"
    t.string "name"
    t.string "avatar"
    t.boolean "is_owner"
    t.boolean "is_admin"
    t.boolean "is_app_user"
    t.boolean "is_deleted"
    t.string "timestamps"
    t.integer "team_id", null: false
    t.index ["team_id"], name: "index_members_on_team_id"
  end

  create_table "slack_users", force: :cascade do |t|
    t.string "slack_user_id"
    t.string "scope"
    t.string "access_token"
    t.integer "team_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "avatar"
    t.string "name"
    t.index ["team_id"], name: "index_slack_users_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "slack_id"
    t.string "slack_name"
    t.string "bot_user_id"
    t.string "bot_access_token"
    t.string "scope"
    t.string "enterprise"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "conversation_members", "conversations"
  add_foreign_key "conversation_members", "members"
  add_foreign_key "conversations", "slack_users"
  add_foreign_key "conversations", "teams"
  add_foreign_key "members", "teams"
  add_foreign_key "slack_users", "teams"
end

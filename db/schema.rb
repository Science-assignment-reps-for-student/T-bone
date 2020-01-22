# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_17_101121) do

  create_table "chats", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "chat_message", null: false
    t.bigint "created_at", null: false
    t.index ["user_id"], name: "index_chats_on_user_id"
  end

  create_table "codes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "auth_code", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_codes_on_user_id"
  end

  create_table "excel_files", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "homework_id"
    t.string "source", null: false
    t.index ["homework_id"], name: "index_excel_files_on_homework_id"
  end

  create_table "homeworks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "homework_1_deadline", null: false
    t.bigint "homework_2_deadline", null: false
    t.bigint "homework_3_deadline", null: false
    t.bigint "homework_4_deadline", null: false
    t.string "homework_title", null: false
    t.string "homework_description", null: false
    t.integer "homework_type", null: false
    t.bigint "created_at", null: false
  end

  create_table "members", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "team_id"
    t.bigint "user_id"
    t.index ["team_id"], name: "index_members_on_team_id"
    t.index ["user_id"], name: "index_members_on_user_id"
  end

  create_table "multi_files", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "team_id"
    t.bigint "homework_id"
    t.string "source", null: false
    t.integer "created_at", null: false
    t.index ["homework_id"], name: "index_multi_files_on_homework_id"
    t.index ["team_id"], name: "index_multi_files_on_team_id"
  end

  create_table "mutual_evaluations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "homework_id"
    t.bigint "team_id"
    t.bigint "target_id"
    t.index ["homework_id"], name: "index_mutual_evaluations_on_homework_id"
    t.index ["target_id"], name: "index_mutual_evaluations_on_target_id"
    t.index ["team_id"], name: "index_mutual_evaluations_on_team_id"
    t.index ["user_id", "target_id", "homework_id"], name: "redundancy_check", unique: true
    t.index ["user_id"], name: "index_mutual_evaluations_on_user_id"
  end

  create_table "notice_files", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "homework_id"
    t.string "source", null: false
    t.index ["homework_id"], name: "index_notice_files_on_homework_id"
  end

  create_table "self_evaluations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "homework_id"
    t.bigint "team_id"
    t.integer "scientific_accuracy", null: false
    t.integer "communication", null: false
    t.integer "attitude", null: false
    t.index ["homework_id"], name: "index_self_evaluations_on_homework_id"
    t.index ["team_id"], name: "index_self_evaluations_on_team_id"
    t.index ["user_id"], name: "index_self_evaluations_on_user_id"
  end

  create_table "single_files", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "homework_id"
    t.string "source", null: false
    t.bigint "created_at", null: false
    t.boolean "late", default: false
    t.index ["homework_id"], name: "index_single_files_on_homework_id"
    t.index ["user_id"], name: "index_single_files_on_user_id"
  end

  create_table "teams", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "leader_id"
    t.bigint "homework_id"
    t.string "team_name"
    t.index ["homework_id"], name: "index_teams_on_homework_id"
    t.index ["leader_id"], name: "index_teams_on_leader_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "user_email", null: false
    t.string "user_pw", null: false
    t.integer "user_number"
    t.string "user_name", null: false
    t.integer "user_type", default: 0
  end

  add_foreign_key "mutual_evaluations", "users", column: "target_id"
  add_foreign_key "teams", "users", column: "leader_id"
end

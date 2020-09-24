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

ActiveRecord::Schema.define(version: 2020_09_14_102520) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.string "access_token"
    t.string "role"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "claim_reviews", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "img_review_started"
    t.integer "vid_review_started"
    t.integer "img_old"
    t.integer "img_forensic_discrepency"
    t.integer "img_metadata_discrepency"
    t.integer "img_logical_discrepency"
    t.integer "vid_old"
    t.integer "vid_forensic_discrepency"
    t.integer "vid_metadata_discrepency"
    t.integer "vid_audio_discrepency"
    t.integer "vid_logical_discrepency"
    t.integer "txt_unreliable_news_content"
    t.integer "txt_insufficient_verifiable_srcs"
    t.integer "txt_has_clickbait"
    t.integer "txt_poor_language"
    t.integer "txt_crowds_distance_discrepency"
    t.integer "txt_author_offers_little_evidence"
    t.integer "txt_reliable_sources_disapprove"
    t.integer "review_verdict"
    t.text "review_description"
    t.integer "review_sharing_mode"
    t.boolean "review_is_complete"
    t.text "review_published_url"
    t.string "note_img_old"
    t.string "note_img_forensic_discrepency"
    t.string "note_img_metadata_discrepency"
    t.string "note_img_logical_discrepency"
    t.string "note_vid_old"
    t.string "note_vid_forensic_discrepency"
    t.string "note_vid_metadata_discrepency"
    t.string "note_vid_audio_discrepency"
    t.string "note_vid_logical_discrepency"
    t.string "note_txt_unreliable_news_content"
    t.string "note_txt_insufficient_verifiable_srcs"
    t.string "note_txt_has_clickbait"
    t.string "note_txt_poor_language"
    t.string "note_txt_crowds_distance_discrepency"
    t.string "note_txt_author_offers_little_evidence"
    t.string "note_txt_reliable_sources_disapprove"
    t.string "note_review_verdict"
    t.string "note_review_description"
    t.string "note_review_sharing_mode"
    t.string "note_review_published_url"
    t.integer "user_id"
    t.integer "claim_id"
    t.integer "txt_review_started"
    t.integer "add_to_blockchain"
    t.datetime "time_added_to_blockchain"
    t.string "blockchain_tx"
    t.string "blockchain_id"
    t.integer "blockchain_assessment"
    t.string "blockchain_assessment_rationale"
    t.string "blockchain_assessment_admin_id"
    t.datetime "blockchain_assessment_time"
    t.string "blockchain_assessment_tx"
    t.index ["review_verdict"], name: "index_claim_reviews_on_review_verdict"
  end

  create_table "claims", force: :cascade do |t|
    t.integer "has_image"
    t.string "title"
    t.string "url"
    t.integer "medium_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "src_id"
    t.integer "has_video"
    t.integer "has_text"
    t.text "url_preview"
    t.integer "sharing_mode"
    t.integer "add_to_blockchain"
    t.datetime "expiry_date"
    t.integer "reward_amount"
    t.string "conditions"
    t.datetime "time_added_to_blockchain"
    t.string "blockchain_tx"
    t.string "blockchain_id"
    t.string "status_on_blockchain"
    t.index ["medium_id"], name: "index_claims_on_medium_id"
    t.index ["title"], name: "index_claims_on_title"
    t.index ["url"], name: "index_claims_on_url"
  end

  create_table "media", force: :cascade do |t|
    t.text "url"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "medium_type"
    t.string "name"
    t.text "url_preview"
    t.integer "sharing_mode"
    t.index ["name"], name: "index_media_on_name", unique: true
    t.index ["url"], name: "index_media_on_url"
  end

  create_table "medium_reviews", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "medium_review_started"
    t.integer "medium_is_blacklisted"
    t.integer "medium_failed_factcheck_before"
    t.integer "medium_has_poor_security"
    t.integer "medium_whois_info_discrepency"
    t.integer "medium_hosting_discrepency"
    t.integer "medium_is_biased"
    t.integer "medium_is_poorly_ranked"
    t.integer "medium_is_not_liable"
    t.integer "medium_lacks_flagging_means"
    t.text "medium_other_problems"
    t.integer "medium_review_verdict"
    t.text "medium_review_description"
    t.integer "medium_review_sharing_mode"
    t.boolean "medium_review_is_completed"
    t.string "note_medium_is_blacklisted"
    t.string "note_medium_failed_factcheck_before"
    t.string "note_medium_has_poor_security"
    t.string "note_medium_whois_info_discrepency"
    t.string "note_medium_hosting_discrepency"
    t.string "note_medium_is_biased"
    t.string "note_medium_is_poorly_ranked"
    t.string "note_medium_is_not_liable"
    t.string "note_medium_lacks_flagging_means"
    t.string "note_medium_other_problems"
    t.string "note_medium_review_verdict"
    t.string "note_medium_review_description"
    t.string "note_medium_review_sharing_mode"
    t.integer "user_id"
    t.integer "medium_id"
    t.index ["medium_id"], name: "index_medium_reviews_on_medium_id"
    t.index ["medium_review_sharing_mode"], name: "index_medium_reviews_on_medium_review_sharing_mode"
    t.index ["medium_review_verdict"], name: "index_medium_reviews_on_medium_review_verdict"
  end

  create_table "resources", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "tutorial"
    t.text "icon"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "used_for_qs"
    t.string "url"
    t.text "url_preview"
    t.index ["name"], name: "index_resources_on_name", unique: true
    t.index ["url"], name: "index_resources_on_url"
  end

  create_table "src_reviews", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "src_review_started"
    t.integer "src_lacks_proper_credentials"
    t.integer "src_failed_factcheck_before"
    t.integer "src_has_poor_writing_history"
    t.integer "src_supported_by_trolls"
    t.integer "src_difficult_to_locate"
    t.integer "src_other_problems"
    t.integer "src_review_verdict"
    t.text "src_review_description"
    t.integer "src_review_sharing_mode"
    t.boolean "src_review_is_completed"
    t.string "note_src_lacks_proper_credentials"
    t.string "note_src_failed_factcheck_before"
    t.string "note_src_has_poor_writing_history"
    t.string "note_src_supported_by_trolls"
    t.string "note_src_difficult_to_locate"
    t.string "note_src_other_problems"
    t.string "note_src_review_verdict"
    t.string "note_src_review_description"
    t.string "note_src_review_sharing_mode"
    t.integer "user_id"
    t.integer "src_id"
    t.index ["src_id"], name: "index_src_reviews_on_src_id"
    t.index ["src_review_sharing_mode"], name: "index_src_reviews_on_src_review_sharing_mode"
    t.index ["src_review_verdict"], name: "index_src_reviews_on_src_review_verdict"
  end

  create_table "srcs", force: :cascade do |t|
    t.text "url"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "src_type"
    t.string "name"
    t.text "url_preview"
    t.integer "sharing_mode"
    t.index ["name"], name: "index_srcs_on_name", unique: true
    t.index ["url"], name: "index_srcs_on_url"
  end

  create_table "taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "claim_id"
    t.integer "medium_id"
    t.integer "src_id"
    t.integer "resource_id"
    t.integer "tag_id"
    t.index ["claim_id"], name: "index_tags_on_claim_id"
    t.index ["medium_id"], name: "index_tags_on_medium_id"
    t.index ["resource_id"], name: "index_tags_on_resource_id"
    t.index ["src_id"], name: "index_tags_on_src_id"
    t.index ["tag_id"], name: "index_tags_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "claim_name"
    t.string "medium_name"
    t.string "src_name"
    t.string "resource_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_name"], name: "index_tags_on_claim_name", unique: true
    t.index ["medium_name"], name: "index_tags_on_medium_name", unique: true
    t.index ["resource_name"], name: "index_tags_on_resource_name", unique: true
    t.index ["src_name"], name: "index_tags_on_src_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "affiliation"
    t.string "name"
    t.string "role", default: "user"
    t.string "url"
    t.string "details"
    t.string "authentication_token", limit: 30
    t.integer "add_to_blockchain"
    t.datetime "time_added_to_blockchain"
    t.string "blockchain_tx"
    t.string "blockchain_id"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end

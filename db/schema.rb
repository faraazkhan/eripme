# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130107052664) do

  create_table "accounts", :force => true do |t|
    t.string   "email",                                       :null => false
    t.string   "password_hash",                               :null => false
    t.string   "role",          :limit => 20,                 :null => false
    t.integer  "parent_id",                                   :null => false
    t.string   "parent_type",   :limit => 20,                 :null => false
    t.integer  "timezone",                    :default => -5, :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "last_login_ip"
    t.datetime "last_login_at"
  end

  add_index "accounts", ["email"], :name => "accounts_email_idx"
  add_index "accounts", ["parent_id"], :name => "accounts_par_id_idx"

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "addresses", :force => true do |t|
    t.string   "address"
    t.string   "address2"
    t.string   "address3"
    t.string   "city",             :default => ""
    t.string   "state",            :default => ""
    t.string   "zip_code",         :default => ""
    t.string   "country",          :default => "United States of America"
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address_type",     :default => "Property"
    t.float    "lat"
    t.float    "lng"
    t.string   "verified_address"
    t.string   "geocoded_address"
  end

  add_index "addresses", ["address_type"], :name => "addresses_address_type_idx"
  add_index "addresses", ["addressable_id"], :name => "addresses_addressable_id_idx"
  add_index "addresses", ["addressable_type"], :name => "addresses_addressable_type_idx"
  add_index "addresses", ["zip_code"], :name => "addresses_zip_code_idx"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "role"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "agents", :force => true do |t|
    t.string  "name",                  :default => "", :null => false
    t.string  "email",                 :default => "", :null => false
    t.integer "admin",                 :default => 0,  :null => false
    t.integer "commission_percentage", :default => 8,  :null => false
  end

  add_index "agents", ["email"], :name => "agents_email_idx"
  add_index "agents", ["name"], :name => "agents_name_idx"

  create_table "bdrb_job_queues", :force => true do |t|
    t.binary   "args"
    t.string   "worker_name"
    t.string   "worker_method"
    t.string   "job_key"
    t.integer  "taken"
    t.integer  "finished"
    t.integer  "timeout"
    t.integer  "priority"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.string   "tag"
    t.string   "submitter_info"
    t.string   "runner_info"
    t.string   "worker_key"
    t.datetime "scheduled_at"
  end

  create_table "cancellation_reasons", :force => true do |t|
    t.string   "reason",     :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "claims", :force => true do |t|
    t.integer  "customer_id"
    t.string   "claim_timestamp"
    t.text     "claim_text"
    t.string   "standard_coverage"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "address_id"
    t.string   "agent_name"
    t.integer  "status_code",       :default => 0
  end

  add_index "claims", ["claim_timestamp"], :name => "claims_tstamp_idx"
  add_index "claims", ["customer_id"], :name => "claims_cust_id_idx"

  create_table "cms_attachment_versions", :force => true do |t|
    t.integer  "original_record_id"
    t.integer  "version"
    t.string   "data_file_path"
    t.string   "file_location"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "data_file_name"
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "data_fingerprint"
    t.string   "attachable_type"
    t.string   "attachment_name"
    t.integer  "attachable_id"
    t.integer  "attachable_version"
    t.string   "cardinality"
  end

  add_index "cms_attachment_versions", ["original_record_id"], :name => "index_cms_attachment_versions_on_original_record_id"

  create_table "cms_attachments", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",       :default => 0
    t.string   "data_file_path"
    t.string   "file_location"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "data_file_name"
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "data_fingerprint"
    t.string   "attachable_type"
    t.string   "attachment_name"
    t.integer  "attachable_id"
    t.integer  "attachable_version"
    t.string   "cardinality"
  end

  create_table "cms_categories", :force => true do |t|
    t.integer  "category_type_id"
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "cms_category_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cms_connectors", :force => true do |t|
    t.integer  "page_id"
    t.integer  "page_version"
    t.integer  "connectable_id"
    t.string   "connectable_type"
    t.integer  "connectable_version"
    t.string   "container"
    t.integer  "position"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "cms_connectors", ["connectable_type"], :name => "index_cms_connectors_on_connectable_type"
  add_index "cms_connectors", ["connectable_version"], :name => "index_cms_connectors_on_connectable_version"
  add_index "cms_connectors", ["page_id"], :name => "index_cms_connectors_on_page_id"
  add_index "cms_connectors", ["page_version"], :name => "index_cms_connectors_on_page_version"

  create_table "cms_content_type_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cms_content_types", :force => true do |t|
    t.string   "name"
    t.integer  "content_type_group_id"
    t.integer  "priority",              :default => 2
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "cms_content_types", ["content_type_group_id"], :name => "index_cms_content_types_on_content_type_group_id"
  add_index "cms_content_types", ["name"], :name => "index_cms_content_types_on_name"

  create_table "cms_dynamic_view_versions", :force => true do |t|
    t.integer  "original_record_id"
    t.integer  "version"
    t.string   "type"
    t.string   "name"
    t.string   "format"
    t.string   "handler"
    t.text     "body"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "cms_dynamic_views", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",  :default => 0
    t.string   "type"
    t.string   "name"
    t.string   "format"
    t.string   "handler"
    t.text     "body"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "published",     :default => false
    t.boolean  "deleted",       :default => false
    t.boolean  "archived",      :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "cms_email_messages", :force => true do |t|
    t.string   "sender"
    t.text     "recipients"
    t.text     "subject"
    t.text     "cc"
    t.text     "bcc"
    t.text     "body"
    t.string   "content_type"
    t.datetime "delivered_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "cms_file_block_versions", :force => true do |t|
    t.integer  "original_record_id"
    t.integer  "version"
    t.string   "type"
    t.string   "name"
    t.integer  "attachment_id"
    t.integer  "attachment_version"
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "cms_file_block_versions", ["original_record_id"], :name => "index_cms_file_block_versions_on_original_record_id"
  add_index "cms_file_block_versions", ["version"], :name => "index_cms_file_block_versions_on_version"

  create_table "cms_file_blocks", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",       :default => 0
    t.string   "type"
    t.string   "name"
    t.integer  "attachment_id"
    t.integer  "attachment_version"
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "cms_file_blocks", ["deleted"], :name => "index_cms_file_blocks_on_deleted"
  add_index "cms_file_blocks", ["type"], :name => "index_cms_file_blocks_on_type"

  create_table "cms_group_permissions", :force => true do |t|
    t.integer "group_id"
    t.integer "permission_id"
  end

  add_index "cms_group_permissions", ["group_id", "permission_id"], :name => "index_cms_group_permissions_on_group_id_and_permission_id"
  add_index "cms_group_permissions", ["group_id"], :name => "index_cms_group_permissions_on_group_id"
  add_index "cms_group_permissions", ["permission_id"], :name => "index_cms_group_permissions_on_permission_id"

  create_table "cms_group_sections", :force => true do |t|
    t.integer "group_id"
    t.integer "section_id"
  end

  add_index "cms_group_sections", ["group_id"], :name => "index_cms_group_sections_on_group_id"
  add_index "cms_group_sections", ["section_id"], :name => "index_cms_group_sections_on_section_id"

  create_table "cms_group_type_permissions", :force => true do |t|
    t.integer "group_type_id"
    t.integer "permission_id"
  end

  create_table "cms_group_types", :force => true do |t|
    t.string   "name"
    t.boolean  "guest",      :default => false
    t.boolean  "cms_access", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "cms_group_types", ["cms_access"], :name => "index_cms_group_types_on_cms_access"

  create_table "cms_groups", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.integer  "group_type_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "cms_groups", ["code"], :name => "index_cms_groups_on_code"
  add_index "cms_groups", ["group_type_id"], :name => "index_cms_groups_on_group_type_id"

  create_table "cms_html_block_versions", :force => true do |t|
    t.integer  "original_record_id"
    t.integer  "version"
    t.string   "name"
    t.text     "content",            :limit => 16777215
    t.boolean  "published",                              :default => false
    t.boolean  "deleted",                                :default => false
    t.boolean  "archived",                               :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
  end

  add_index "cms_html_block_versions", ["original_record_id"], :name => "index_cms_html_block_versions_on_original_record_id"
  add_index "cms_html_block_versions", ["version"], :name => "index_cms_html_block_versions_on_version"

  create_table "cms_html_blocks", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",                      :default => 0
    t.string   "name"
    t.text     "content",       :limit => 16777215
    t.boolean  "published",                         :default => false
    t.boolean  "deleted",                           :default => false
    t.boolean  "archived",                          :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
  end

  add_index "cms_html_blocks", ["deleted"], :name => "index_cms_html_blocks_on_deleted"

  create_table "cms_link_versions", :force => true do |t|
    t.integer  "original_record_id"
    t.integer  "version"
    t.string   "name"
    t.string   "url"
    t.boolean  "new_window",         :default => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "cms_links", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",   :default => 0
    t.string   "name"
    t.string   "url"
    t.boolean  "new_window",     :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "published",      :default => false
    t.boolean  "deleted",        :default => false
    t.boolean  "archived",       :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "latest_version"
  end

  create_table "cms_page_route_options", :force => true do |t|
    t.integer  "page_route_id"
    t.string   "type"
    t.string   "name"
    t.string   "value"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "cms_page_routes", :force => true do |t|
    t.string   "name"
    t.string   "pattern"
    t.integer  "page_id"
    t.text     "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cms_page_versions", :force => true do |t|
    t.integer  "original_record_id"
    t.integer  "version"
    t.string   "name"
    t.string   "title"
    t.string   "path"
    t.string   "template_file_name"
    t.text     "description"
    t.text     "keywords"
    t.string   "language"
    t.boolean  "cacheable",          :default => false
    t.boolean  "hidden",             :default => false
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "cms_page_versions", ["original_record_id"], :name => "index_cms_page_versions_on_original_record_id"

  create_table "cms_pages", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",       :default => 0
    t.string   "name"
    t.string   "title"
    t.string   "path"
    t.string   "template_file_name"
    t.text     "description"
    t.text     "keywords"
    t.string   "language"
    t.boolean  "cacheable",          :default => false
    t.boolean  "hidden",             :default => false
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "latest_version"
  end

  add_index "cms_pages", ["deleted"], :name => "index_cms_pages_on_deleted"
  add_index "cms_pages", ["path"], :name => "index_cms_pages_on_path"
  add_index "cms_pages", ["version"], :name => "index_cms_pages_on_version"

  create_table "cms_permissions", :force => true do |t|
    t.string   "name"
    t.string   "full_name"
    t.string   "description"
    t.string   "for_module"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "cms_portlet_attributes", :force => true do |t|
    t.integer "portlet_id"
    t.string  "name"
    t.text    "value"
  end

  add_index "cms_portlet_attributes", ["portlet_id"], :name => "index_cms_portlet_attributes_on_portlet_id"

  create_table "cms_portlets", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.boolean  "archived",      :default => false
    t.boolean  "deleted",       :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "cms_portlets", ["name"], :name => "index_cms_portlets_on_name"

  create_table "cms_redirects", :force => true do |t|
    t.string   "from_path"
    t.string   "to_path"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "cms_redirects", ["from_path"], :name => "index_cms_redirects_on_from_path"

  create_table "cms_section_nodes", :force => true do |t|
    t.string   "node_type"
    t.integer  "node_id"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "ancestry"
  end

  add_index "cms_section_nodes", ["ancestry"], :name => "index_cms_section_nodes_on_ancestry"
  add_index "cms_section_nodes", ["node_type"], :name => "index_cms_section_nodes_on_node_type"

  create_table "cms_sections", :force => true do |t|
    t.string   "name"
    t.string   "path"
    t.boolean  "root",       :default => false
    t.boolean  "hidden",     :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "cms_sections", ["path"], :name => "index_cms_sections_on_path"

  create_table "cms_sites", :force => true do |t|
    t.string   "name"
    t.string   "domain"
    t.boolean  "the_default"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "cms_taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "taggable_version"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "cms_tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cms_tasks", :force => true do |t|
    t.integer  "assigned_by_id"
    t.integer  "assigned_to_id"
    t.integer  "page_id"
    t.text     "comment"
    t.date     "due_date"
    t.datetime "completed_at"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "cms_tasks", ["assigned_to_id"], :name => "index_cms_tasks_on_assigned_to_id"
  add_index "cms_tasks", ["completed_at"], :name => "index_cms_tasks_on_completed_at"
  add_index "cms_tasks", ["page_id"], :name => "index_cms_tasks_on_page_id"

  create_table "cms_user_group_memberships", :force => true do |t|
    t.integer "user_id"
    t.integer "group_id"
  end

  add_index "cms_user_group_memberships", ["group_id"], :name => "index_cms_user_group_memberships_on_group_id"
  add_index "cms_user_group_memberships", ["user_id"], :name => "index_cms_user_group_memberships_on_user_id"

  create_table "cms_users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "first_name",                :limit => 40
    t.string   "last_name",                 :limit => 40
    t.string   "email",                     :limit => 40
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "reset_token"
  end

  add_index "cms_users", ["expires_at"], :name => "index_cms_users_on_expires_at"
  add_index "cms_users", ["login"], :name => "index_cms_users_on_login", :unique => true

  create_table "content", :force => true do |t|
    t.string   "slug",       :null => false
    t.text     "html",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content", ["slug"], :name => "content_slug_index"

  create_table "contractor_payments", :force => true do |t|
    t.integer  "contractor_id"
    t.float    "amount"
    t.integer  "repair_id"
    t.datetime "paid_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contractors", :force => true do |t|
    t.string   "first_name",         :default => "",      :null => false
    t.string   "last_name",          :default => "",      :null => false
    t.string   "company",                                 :null => false
    t.string   "job_title",          :default => "",      :null => false
    t.string   "phone",              :default => "",      :null => false
    t.string   "mobile",             :default => "",      :null => false
    t.string   "fax",                :default => "",      :null => false
    t.string   "email",              :default => "",      :null => false
    t.string   "priority",           :default => "",      :null => false
    t.string   "notes",              :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "receive_invoice_as", :default => "email"
    t.integer  "rating",             :default => 0
    t.boolean  "flagged",            :default => false
    t.string   "url"
  end

  create_table "coverages", :force => true do |t|
    t.string  "coverage_name"
    t.integer "optional",      :default => 0
    t.float   "price",         :default => 0.0
  end

  create_table "coverages_packages", :id => false, :force => true do |t|
    t.integer "coverage_id"
    t.integer "package_id"
  end

  create_table "credit_cards", :force => true do |t|
    t.string   "crypted_number"
    t.string   "last_4"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.integer  "customer_id"
    t.integer  "month"
    t.integer  "year"
    t.integer  "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", :force => true do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "customer_address"
    t.string   "customer_city"
    t.string   "customer_state"
    t.string   "customer_zip"
    t.string   "customer_phone"
    t.integer  "coverage_type",                            :default => 1
    t.string   "coverage_addon"
    t.string   "home_type",                 :limit => 20
    t.string   "pay_amount"
    t.integer  "num_payments",                             :default => 0
    t.integer  "disabled",                                 :default => 1
    t.integer  "coverage_end"
    t.datetime "coverage_ends_at"
    t.string   "subscription_id"
    t.integer  "validated",                                :default => 0
    t.string   "customer_comment",          :limit => 512
    t.string   "credit_card_number_hash",   :limit => 500
    t.string   "expirationDate"
    t.integer  "status_id",                                :default => 0, :null => false
    t.integer  "timestamp"
    t.string   "ip"
    t.string   "billing_first_name"
    t.string   "billing_last_name"
    t.string   "billing_address"
    t.string   "billing_city"
    t.string   "billing_state"
    t.string   "billing_zip"
    t.integer  "agent_id"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.integer  "discount_id"
    t.integer  "cancellation_reason_id"
    t.integer  "icontact_id"
    t.string   "from"
    t.string   "service_fee_text_override"
    t.float    "service_fee_amt_override"
    t.string   "wait_period_text_override"
    t.integer  "wait_period_days_override"
    t.integer  "num_payments_override"
    t.string   "payment_schedule_override"
    t.string   "notes_override"
    t.integer  "home_size_code"
    t.integer  "home_occupancy_code"
    t.string   "work_phone"
    t.string   "mobile_phone"
  end

  add_index "customers", ["agent_id"], :name => "customers_agent_id_idx"
  add_index "customers", ["customer_city"], :name => "customers_city_idx"
  add_index "customers", ["customer_state"], :name => "customers_state_idx"
  add_index "customers", ["customer_zip"], :name => "customers_zip_idx"
  add_index "customers", ["email"], :name => "customers_email_idx"
  add_index "customers", ["last_name"], :name => "customers_last_name_idx"
  add_index "customers", ["status_id"], :name => "customers_status_id_idx"

  create_table "discounts", :force => true do |t|
    t.boolean  "is_monthly"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.float    "value"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_templates", :force => true do |t|
    t.string  "name",    :default => "",    :null => false
    t.text    "subject",                    :null => false
    t.text    "body",                       :null => false
    t.boolean "locked",  :default => false
  end

  create_table "fax_assignable_joins", :force => true do |t|
    t.integer  "fax_id"
    t.integer  "assignable_id"
    t.string   "assignable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fax_sources", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "number"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "password_hash"
  end

  create_table "faxes", :force => true do |t|
    t.string   "path"
    t.datetime "received_at"
    t.string   "sender_fax_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_id"
    t.integer  "message_id"
  end

  create_table "i_contact_requests", :force => true do |t|
    t.string   "path",                      :null => false
    t.string   "put",        :limit => 512
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", :force => true do |t|
    t.integer  "customer_id", :default => 0, :null => false
    t.text     "note_text",                  :null => false
    t.integer  "timestamp",   :default => 0, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "repair_id"
    t.integer  "author_id"
    t.string   "agent_name"
  end

  add_index "notes", ["customer_id"], :name => "notes_cust_id_idx"

  create_table "notifications", :force => true do |t|
    t.string   "message"
    t.string   "notification_type"
    t.integer  "level",             :default => 0
    t.integer  "subject_id"
    t.string   "subject_type"
    t.string   "subject_summary"
    t.integer  "actor_id"
    t.string   "actor_type"
    t.string   "actor_summary"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "packages", :force => true do |t|
    t.string "package_name"
    t.float  "single_price",   :default => 0.0
    t.float  "condo_price",    :default => 0.0
    t.float  "duplex_price",                    :null => false
    t.float  "triplex_price",                   :null => false
    t.float  "fourplex_price",                  :null => false
  end

  create_table "properties", :force => true do |t|
    t.integer  "customer_id"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "properties", ["city"], :name => "properties_city_idx"
  add_index "properties", ["customer_id"], :name => "properties_cust_id_idx"
  add_index "properties", ["state"], :name => "properties_state_idx"
  add_index "properties", ["zip"], :name => "properties_zip_idx"

  create_table "referals", :primary_key => "referal_id", :force => true do |t|
    t.string  "referal_text", :default => "", :null => false
    t.integer "timestamp",    :default => 0,  :null => false
  end

  create_table "renewals", :force => true do |t|
    t.date     "starts_at"
    t.date     "ends_at"
    t.float    "amount"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "years",       :default => 0
  end

  create_table "repairs", :force => true do |t|
    t.integer  "claim_id"
    t.integer  "contractor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authorization",  :default => 0,    :null => false
    t.float    "amount",         :default => 0.0,  :null => false
    t.integer  "status",         :default => 0
    t.float    "service_charge", :default => 60.0
  end

  create_table "signature_hashes", :force => true do |t|
    t.text     "signature_hash"
    t.integer  "account_id",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "response_code"
    t.string   "response_reason_text"
    t.string   "auth_code"
    t.float    "amount"
    t.integer  "transaction_id"
    t.integer  "customer_id"
    t.integer  "subscription_id"
    t.integer  "subscription_paynum"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "original_agent_id"
  end

  add_index "transactions", ["customer_id"], :name => "transactions_cust_id_idx"
  add_index "transactions", ["original_agent_id"], :name => "transactions_orig_agent_id_idx"
  add_index "transactions", ["response_code"], :name => "response_code_index"
  add_index "transactions", ["subscription_id"], :name => "transactions_subs_id_idx"
  add_index "transactions", ["transaction_id"], :name => "transactions_trans_id_idx"

end

# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 1199056420) do

  create_table "asset_versions", :force => true do |t|
    t.column "asset_id",       :integer
    t.column "version",        :integer
    t.column "parent_id",      :integer
    t.column "content_type",   :string
    t.column "filename",       :string
    t.column "thumbnail",      :string
    t.column "size",           :integer
    t.column "width",          :integer
    t.column "height",         :integer
    t.column "page_id",        :integer
    t.column "created_at",     :datetime
    t.column "versioned_type", :string
    t.column "updated_at",     :datetime
  end

  add_index "asset_versions", ["asset_id"], :name => "index_asset_versions_asset_id"
  add_index "asset_versions", ["parent_id"], :name => "index_asset_versions_parent_id"
  add_index "asset_versions", ["version"], :name => "index_asset_versions_version"
  add_index "asset_versions", ["page_id"], :name => "index_asset_versions_page_id"

  create_table "assets", :force => true do |t|
    t.column "parent_id",    :integer
    t.column "content_type", :string
    t.column "filename",     :string
    t.column "thumbnail",    :string
    t.column "size",         :integer
    t.column "width",        :integer
    t.column "height",       :integer
    t.column "type",         :string
    t.column "page_id",      :integer
    t.column "created_at",   :datetime
    t.column "version",      :integer
  end

  add_index "assets", ["parent_id"], :name => "index_assets_parent_id"
  add_index "assets", ["version"], :name => "index_assets_version"
  add_index "assets", ["page_id"], :name => "index_assets_page_id"

  create_table "avatars", :force => true do |t|
    t.column "data",   :binary
    t.column "public", :boolean, :default => false
  end

  create_table "categories", :force => true do |t|
  end

  create_table "channels", :force => true do |t|
    t.column "name",     :string
    t.column "group_id", :integer
    t.column "public",   :boolean, :default => false
  end

  add_index "channels", ["group_id"], :name => "index_channels_group_id"

  create_table "channels_users", :force => true do |t|
    t.column "channel_id", :integer
    t.column "user_id",    :integer
    t.column "last_seen",  :datetime
  end

  add_index "channels_users", ["channel_id", "user_id"], :name => "index_channels_users"

  create_table "contacts", :id => false, :force => true do |t|
    t.column "user_id",    :integer
    t.column "contact_id", :integer
  end

  add_index "contacts", ["contact_id", "user_id"], :name => "index_contacts"

  create_table "discussions", :force => true do |t|
    t.column "posts_count",  :integer,  :default => 0
    t.column "replied_at",   :datetime
    t.column "replied_by",   :integer
    t.column "last_post_id", :integer
    t.column "page_id",      :integer
  end

  add_index "discussions", ["page_id"], :name => "index_discussions_page_id"

  create_table "email_addresses", :force => true do |t|
    t.column "profile_id",    :integer
    t.column "preferred",     :boolean, :default => false
    t.column "email_type",    :string
    t.column "email_address", :string
  end

  add_index "email_addresses", ["profile_id"], :name => "email_addresses_profile_id_index"

  create_table "events", :force => true do |t|
    t.column "description",      :text
    t.column "description_html", :text
    t.column "is_all_day",       :boolean, :default => false
    t.column "is_cancelled",     :boolean, :default => false
    t.column "is_tentative",     :boolean, :default => true
    t.column "location",         :string
  end

  create_table "federations", :force => true do |t|
    t.column "group_id",     :integer
    t.column "network_id",   :integer
    t.column "council_id",   :integer
    t.column "delegates_id", :integer
  end

  create_table "group_participations", :force => true do |t|
    t.column "group_id", :integer
    t.column "page_id",  :integer
    t.column "access",   :integer
  end

  add_index "group_participations", ["group_id", "page_id"], :name => "index_group_participations"

  create_table "groups", :force => true do |t|
    t.column "name",           :string
    t.column "full_name",      :string
    t.column "summary",        :string
    t.column "url",            :string
    t.column "type",           :string
    t.column "parent_id",      :integer
    t.column "admin_group_id", :integer
    t.column "council",        :boolean
    t.column "created_at",     :datetime
    t.column "updated_at",     :datetime
    t.column "avatar_id",      :integer
    t.column "style",          :string
  end

  add_index "groups", ["name"], :name => "index_groups_on_name"
  add_index "groups", ["parent_id"], :name => "index_groups_parent_id"

  create_table "im_addresses", :force => true do |t|
    t.column "profile_id", :integer
    t.column "preferred",  :boolean, :default => false
    t.column "im_type",    :string
    t.column "im_address", :string
  end

  add_index "im_addresses", ["profile_id"], :name => "im_addresses_profile_id_index"

  create_table "links", :id => false, :force => true do |t|
    t.column "page_id",       :integer
    t.column "other_page_id", :integer
  end

  add_index "links", ["page_id", "other_page_id"], :name => "index_links_page_and_other_page"

  create_table "locations", :force => true do |t|
    t.column "profile_id",    :integer
    t.column "preferred",     :boolean, :default => false
    t.column "location_type", :string
    t.column "street",        :string
    t.column "city",          :string
    t.column "state",         :string
    t.column "postal_code",   :string
    t.column "geocode",       :string
    t.column "country_name",  :string
  end

  add_index "locations", ["profile_id"], :name => "locations_profile_id_index"

  create_table "memberships", :force => true do |t|
    t.column "group_id",   :integer
    t.column "user_id",    :integer
    t.column "created_at", :datetime
    t.column "page_id",    :integer
  end

  add_index "memberships", ["group_id", "user_id", "page_id"], :name => "index_memberships"

  create_table "messages", :force => true do |t|
    t.column "created_at",  :datetime
    t.column "type",        :string
    t.column "content",     :text
    t.column "channel_id",  :integer
    t.column "sender_id",   :integer
    t.column "sender_name", :string
    t.column "level",       :string
  end

  add_index "messages", ["channel_id"], :name => "index_messages_on_channel_id"
  add_index "messages", ["sender_id"], :name => "index_messages_channel"

  create_table "page_tools", :force => true do |t|
    t.column "page_id",   :integer
    t.column "tool_id",   :integer
    t.column "tool_type", :string
  end

  add_index "page_tools", ["page_id", "tool_id"], :name => "index_page_tools"

  create_table "pages", :force => true do |t|
    t.column "title",              :string
    t.column "created_at",         :datetime
    t.column "updated_at",         :datetime
    t.column "resolved",           :boolean,  :default => true
    t.column "public",             :boolean
    t.column "created_by_id",      :integer
    t.column "updated_by_id",      :integer
    t.column "summary",            :text
    t.column "type",               :string
    t.column "message_count",      :integer,  :default => 0
    t.column "data_id",            :integer
    t.column "data_type",          :string
    t.column "contributors_count", :integer,  :default => 0
    t.column "posts_count",        :integer,  :default => 0
    t.column "name",               :string
    t.column "group_id",           :integer
    t.column "group_name",         :string
    t.column "updated_by_login",   :string
    t.column "created_by_login",   :string
    t.column "flow",               :integer
    t.column "starts_at",          :datetime
    t.column "ends_at",            :datetime
  end

  add_index "pages", ["name"], :name => "index_pages_on_name"
  add_index "pages", ["created_by_id"], :name => "index_page_created_by_id"
  add_index "pages", ["updated_by_id"], :name => "index_page_updated_by_id"
  add_index "pages", ["group_id"], :name => "index_page_group_id"
  add_index "pages", ["type"], :name => "index_pages_on_type"
  add_index "pages", ["flow"], :name => "index_pages_on_flow"
  add_index "pages", ["public"], :name => "index_pages_on_public"
  add_index "pages", ["resolved"], :name => "index_pages_on_resolved"
  add_index "pages", ["created_at"], :name => "index_pages_on_created_at"
  add_index "pages", ["updated_at"], :name => "index_pages_on_updated_at"
  add_index "pages", ["starts_at"], :name => "index_pages_on_starts_at"
  add_index "pages", ["ends_at"], :name => "index_pages_on_ends_at"

  create_table "phone_numbers", :force => true do |t|
    t.column "profile_id",        :integer
    t.column "preferred",         :boolean, :default => false
    t.column "provider",          :string
    t.column "phone_number_type", :string
    t.column "phone_number",      :string
  end

  add_index "phone_numbers", ["profile_id"], :name => "phone_numbers_profile_id_index"

  create_table "polls", :force => true do |t|
    t.column "type", :string
  end

  create_table "possibles", :force => true do |t|
    t.column "name",             :string
    t.column "action",           :text
    t.column "poll_id",          :integer
    t.column "description",      :text
    t.column "description_html", :text
    t.column "position",         :integer
  end

  add_index "possibles", ["poll_id"], :name => "index_possibles_poll_id"

  create_table "posts", :force => true do |t|
    t.column "user_id",       :integer
    t.column "discussion_id", :integer
    t.column "body",          :text
    t.column "body_html",     :text
    t.column "created_at",    :datetime
    t.column "updated_at",    :datetime
  end

  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"
  add_index "posts", ["discussion_id", "created_at"], :name => "index_posts_on_discussion_id"

  create_table "profile_notes", :force => true do |t|
    t.column "profile_id", :integer
    t.column "preferred",  :boolean, :default => false
    t.column "note_type",  :string
    t.column "body",       :text
  end

  add_index "profile_notes", ["profile_id"], :name => "profile_notes_profile_id_index"

  create_table "profiles", :force => true do |t|
    t.column "entity_id",              :integer
    t.column "entity_type",            :string
    t.column "language",               :string,   :limit => 5
    t.column "stranger",               :boolean
    t.column "peer",                   :boolean
    t.column "friend",                 :boolean
    t.column "foe",                    :boolean
    t.column "name_prefix",            :string
    t.column "first_name",             :string
    t.column "middle_name",            :string
    t.column "last_name",              :string
    t.column "name_suffix",            :string
    t.column "nickname",               :string
    t.column "role",                   :string
    t.column "organization",           :string
    t.column "created_at",             :datetime
    t.column "updated_at",             :datetime
    t.column "birthday",               :string,   :limit => 8
    t.column "fof",                    :boolean
    t.column "summary",                :string
    t.column "wiki_id",                :integer
    t.column "photo_id",               :integer
    t.column "layout_id",              :integer
    t.column "may_see",                :boolean
    t.column "may_see_committees",     :boolean
    t.column "may_see_networks",       :boolean
    t.column "may_see_members",        :boolean
    t.column "may_request_membership", :boolean
    t.column "membership_policy",      :integer
    t.column "may_see_groups",         :boolean
    t.column "may_see_contacts",       :boolean
    t.column "may_request_contact",    :boolean
    t.column "may_pester",             :boolean
    t.column "may_burden",             :boolean
    t.column "may_spy",                :boolean
  end

  add_index "profiles", ["entity_id", "entity_type", "language", "stranger", "peer", "friend", "foe"], :name => "profiles_index"

  create_table "ratings", :force => true do |t|
    t.column "rating",        :integer,                :default => 0
    t.column "created_at",    :datetime,                               :null => false
    t.column "rateable_type", :string,   :limit => 15, :default => "", :null => false
    t.column "rateable_id",   :integer,                :default => 0,  :null => false
    t.column "user_id",       :integer,                :default => 0,  :null => false
  end

  add_index "ratings", ["user_id"], :name => "fk_ratings_user"
  add_index "ratings", ["rateable_type", "rateable_id"], :name => "fk_ratings_rateable"

  create_table "taggings", :force => true do |t|
    t.column "taggable_id",   :integer
    t.column "tag_id",        :integer
    t.column "taggable_type", :string
  end

  add_index "taggings", ["taggable_type", "taggable_id"], :name => "fk_taggings_taggable"

  create_table "tags", :force => true do |t|
    t.column "name", :string
  end

  add_index "tags", ["name"], :name => "tags_name"

  create_table "task_lists", :force => true do |t|
  end

  create_table "tasks", :force => true do |t|
    t.column "task_list_id",     :integer
    t.column "name",             :string
    t.column "description",      :text
    t.column "description_html", :text
    t.column "completed",        :boolean, :default => false
    t.column "position",         :integer
  end

  add_index "tasks", ["task_list_id"], :name => "index_tasks_task_list_id"
  add_index "tasks", ["task_list_id", "completed", "position"], :name => "index_tasks_completed_positions"

  create_table "tasks_users", :id => false, :force => true do |t|
    t.column "user_id", :integer
    t.column "task_id", :integer
  end

  add_index "tasks_users", ["user_id", "task_id"], :name => "index_tasks_users_ids"

  create_table "user_participations", :force => true do |t|
    t.column "page_id",       :integer
    t.column "user_id",       :integer
    t.column "folder_id",     :integer
    t.column "access",        :integer
    t.column "viewed_at",     :datetime
    t.column "changed_at",    :datetime
    t.column "watch",         :boolean,  :default => false
    t.column "star",          :boolean
    t.column "resolved",      :boolean,  :default => true
    t.column "viewed",        :boolean
    t.column "message_count", :integer,  :default => 0
    t.column "attend",        :boolean,  :default => false
    t.column "notice",        :text
  end

  add_index "user_participations", ["page_id"], :name => "index_user_participations_page"
  add_index "user_participations", ["user_id"], :name => "index_user_participations_user"
  add_index "user_participations", ["page_id", "user_id"], :name => "index_user_participations_page_user"
  add_index "user_participations", ["viewed"], :name => "index_user_participations_viewed"
  add_index "user_participations", ["watch"], :name => "index_user_participations_watch"
  add_index "user_participations", ["star"], :name => "index_user_participations_star"
  add_index "user_participations", ["resolved"], :name => "index_user_participations_resolved"
  add_index "user_participations", ["attend"], :name => "index_user_participations_attend"

  create_table "users", :force => true do |t|
    t.column "login",                     :string
    t.column "email",                     :string
    t.column "crypted_password",          :string,   :limit => 40
    t.column "salt",                      :string,   :limit => 40
    t.column "created_at",                :datetime
    t.column "updated_at",                :datetime
    t.column "remember_token",            :string
    t.column "remember_token_expires_at", :datetime
    t.column "display_name",              :string
    t.column "time_zone",                 :string
    t.column "language",                  :string,   :limit => 5
    t.column "avatar_id",                 :integer
    t.column "last_seen_at",              :datetime
    t.column "version",                   :integer,                :default => 0
    t.column "direct_group_id_cache",     :binary
    t.column "all_group_id_cache",        :binary
    t.column "friend_id_cache",           :binary
    t.column "foe_id_cache",              :binary
    t.column "peer_id_cache",             :binary
    t.column "tag_id_cache",              :binary
  end

  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["last_seen_at"], :name => "index_users_on_last_seen_at"

  create_table "votes", :force => true do |t|
    t.column "possible_id", :integer
    t.column "user_id",     :integer
    t.column "created_at",  :datetime
    t.column "value",       :integer
    t.column "comment",     :string
  end

  add_index "votes", ["possible_id"], :name => "index_votes_possible"
  add_index "votes", ["possible_id", "user_id"], :name => "index_votes_possible_and_user"

  create_table "websites", :force => true do |t|
    t.column "profile_id", :integer
    t.column "preferred",  :boolean, :default => false
    t.column "site_title", :string,  :default => ""
    t.column "site_url",   :string,  :default => ""
  end

  add_index "websites", ["profile_id"], :name => "websites_profile_id_index"

  create_table "wiki_versions", :force => true do |t|
    t.column "wiki_id",    :integer
    t.column "version",    :integer
    t.column "body",       :text
    t.column "body_html",  :text
    t.column "updated_at", :datetime
    t.column "user_id",    :integer
  end

  add_index "wiki_versions", ["wiki_id"], :name => "index_wiki_versions"
  add_index "wiki_versions", ["wiki_id", "updated_at"], :name => "index_wiki_versions_with_updated_at"

  create_table "wikis", :force => true do |t|
    t.column "body",         :text
    t.column "body_html",    :text
    t.column "updated_at",   :datetime
    t.column "user_id",      :integer
    t.column "lock_version", :integer,  :default => 0
    t.column "locked_at",    :datetime
    t.column "locked_by_id", :integer
  end

  add_index "wikis", ["user_id"], :name => "index_wikis_user_id"
  add_index "wikis", ["locked_by_id"], :name => "index_wikis_locked_by_id"

end

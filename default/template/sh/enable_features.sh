#!/bin/sh

# enables commonly used stable features

echo enabling the following features:

echo javascript
echo draggable interface
echo openpgp.js and keychain
echo loading indicator
echo php connectors
echo uploading of files
echo permissioned hashtags
echo self-admin
echo operator, please
echo hike set
echo cookie inbox
echo dialog controls

echo 1 > config/setting/admin/js/enable
echo 1 > config/setting/admin/php/enable
echo 1 > config/setting/admin/js/dragging
echo 1 > config/setting/admin/js/loading
echo 1 > config/setting/admin/js/openpgp
echo 1 > config/setting/admin/js/openpgp_keychain
echo 1 > config/setting/admin/upload/enable
echo 1 > config/setting/admin/image/enable
echo 1 > config/setting/admin/allow_admin_permissions_tag_lookup
echo 1 > config/setting/admin/allow_self_admin_when_adminless
#echo 1 > config/setting/admin/token/operator_please
#echo 1 > config/setting/admin/token/hike_set
echo 1 > config/setting/admin/token/http
echo 1 > config/setting/admin/token/https
echo 1 > config/setting/admin/token/remove
echo 1 > config/setting/admin/php/cookie_inbox
echo 1 > config/setting/html/menu_layer_controls
echo 1 > config/setting/admin/php/route_show_cookie
echo 1 > config/setting/admin/php/post/require_cookie
echo 1 > config/setting/admin/logging/log_remote_addr
echo 1 > config/setting/admin/js/profile_auto_register
echo 1 > config/setting/admin/auto_approve_first_user
echo 1 > config/setting/admin/js/openpgp_keygen_prompt_for_username
echo 1 > config/setting/html/avatar_link_to_person_when_approved
echo 1 > config/setting/html/avatar_display_approved_status
echo 1 > config/setting/html/window_titlebar_buttons
echo 1 > config/setting/html/format_item/image_reference
echo 1 > config/setting/html/format_item/address
echo 1 > config/setting/html/format_item/phone
echo 1 > config/setting/html/format_item/textart
echo 1 > config/setting/admin/js/openpgp_checked
echo 1 > config/setting/admin/index/create_system_tags
echo 1 > config/setting/html/item_template/heading_advanced

echo 1 > config/setting/html/item_page_menu_bottom
echo 1 > config/setting/html/item_page/toolbox_timestamps
echo 1 > config/setting/html/item_page/include_notext_in_thread_list
echo 1 > config/setting/html/item_page/toolbox_share
echo 1 > config/setting/html/item_page/toolbox_publish
echo 1 > config/setting/html/item_page/applied_labels
echo 1 > config/setting/html/item_page/toolbox_search
echo 1 > config/setting/html/item_page/replies_list
echo 1 > config/setting/html/item_page/attributes_list
echo 1 > config/setting/html/item_page/parse_log
echo 1 > config/setting/html/item_page/toolbox_classify
echo 1 > config/setting/html/item_page/toolbox_similar_timestamp
echo 1 > config/setting/html/item_page/replies_listing_remove_tokens
echo 1 > config/setting/html/item_page/toolbox_related
echo 1 > config/setting/html/item_page/image_full_size_link
echo 1 > config/setting/html/item_page/replies_listing
echo 1 > config/setting/html/item_page/toolbox_chain_next_previous
echo 1 > config/setting/html/item_page/thread_listing
echo 1 > config/setting/html/item_page/replies_listing_no_titles
echo 1 > config/setting/html/item_page/gpg_stderr
echo 1 > config/setting/html/item_page/toolbox_hashes

echo 0 > config/setting/admin/http_auth/enable
echo 0 > config/setting/admin/welcome_install_message
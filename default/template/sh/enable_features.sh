#!/bin/sh

# roll_over.sh

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
echo 1 > config/setting/admin/token/operator_please
echo 1 > config/setting/admin/token/hike_set
echo 1 > config/setting/admin/php/cookie_index
echo 1 > config/setting/admin/php/regrow_404_fork
echo 1 > config/setting/html/menu_layer_controls
echo 1 > config/setting/admin/php/post/require_cookie
echo 1 > config/setting/admin/js/profile_auto_register
echo 1 > config/setting/admin/auto_approve_first_user
echo 1 > config/setting/admin/js/openpgp_keygen_prompt_for_username
echo 1 > config/setting/html/avatar_link_to_person_when_approved
echo 1 > config/setting/html/avatar_display_approved_status
echo 1 > config/setting/html/window_titlebar_buttons
echo 1 > config/setting/html/page_map_bottom
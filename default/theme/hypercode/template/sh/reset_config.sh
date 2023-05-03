#!/bin/sh

# theme/hypercode/template/sh/reset_config.sh
# reset.sh

rm config/theme/hypercode/template/list/menu
echo 0 > config/setting/admin/js/openpgp
echo 0 > config/setting/admin/upload/enable
echo 0 > config/setting/admin/image/enable
echo 0 > config/setting/admin/js/loading
echo 0 > config/setting/admin/js/dragging
echo 0 > config/setting/admin/js/enable
echo 0 > config/setting/admin/js/debug
echo 1 > config/setting/html/reset_button
echo 0 > config/setting/html/item_page/toolbox_search
echo 0 > config/setting/html/menu_layer_controls
echo 0 > config/setting/html/write_options
echo 0 > config/setting/admin/php/cookie_inbox
echo 0 > config/setting/admin/php/route_notify_printed_time
echo 0 > config/setting/html/css_inline_block
echo 0 > config/setting/html/css_inbox_top
echo 1 > config/setting/html/monochrome
echo 1 > config/setting/html/menu_top
echo 0 > config/setting/html/menu_bottom
echo 0 > config/setting/html/item_page_menu_bottom
#echo 0 > config/setting/admin/index/create_system_tags
echo "hypercode chicago" > config/setting/theme
bash hike.sh frontend


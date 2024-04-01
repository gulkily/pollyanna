#!/bin/sh

# sets up the server for common retro browsers, like netscape 3+, ie4+, and opera 3+

echo 0 > config/setting/admin/js/dragging
echo 0 > config/setting/admin/js/loading
echo 0 > config/setting/admin/js/openpgp
echo 0 > config/setting/html/menu_layer_controls
echo 0 > config/setting/html/window_titlebar_buttons
echo 0 > config/setting/html/page_map_bottom
echo 0 > config/setting/html/page_map_top
echo 0 > config/setting/html/page_map
echo 0 > config/setting/html/menu_top
echo 1 > config/setting/html/menu_bottom
echo 0 > config/setting/html/write_options
echo 0 > config/setting/html/write_settings
echo 1 > config/setting/admin/html/ascii_only
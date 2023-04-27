#!/bin/sh

rm config/theme/hypercode/template/list/menu
echo 0 > config/setting/admin/js/openpgp
echo 0 > config/setting/admin/upload/enable
echo 0 > config/setting/admin/image/enable
echo 0 > config/setting/admin/js/loading
echo 0 > config/setting/admin/js/dragging
echo 0 > config/setting/admin/js/enable
echo 0 > config/setting/html/item_page/toolbox_search
echo 0 > config/setting/html/write_options
echo 0 > config/setting/php/route_notify_printed_time
#echo 0 > config/setting/admin/index/create_system_tags
echo "hypercode chicago" > config/setting/theme
bash hike.sh frontend


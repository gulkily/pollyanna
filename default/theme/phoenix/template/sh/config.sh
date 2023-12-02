#!/bin/sh

echo 1 > config/setting/html/menu_top
echo 0 > config/setting/html/menu_bottom
echo 1 > config/setting/admin/js/loading
echo 1 > config/setting/html/css/theme_concat

cp ./default/res/image/texture/amber.png html/
#!/bin/sh

echo 1 > config/setting/admin/php/post/update_on_post
echo all > config/setting/admin/php/rewrite a
echo 1 > config/setting/admin/token/my_name_is
echo 1 > config/setting/admin/token/title
echo 1 > config/setting/admin/allow_self_admin_when_adminless
echo 1 > config/setting/admin/js/loading
echo 1 > config/setting/admin/js/translit
echo 1 > config/setting/admin/js/fresh
echo 1 > config/setting/admin/image/enable
echo "s * i * * y s e * f . c o m ( . h t m l )" > config/home_title 
echo 1 > config/setting/html/clock
echo epoch > config/setting/html/clock_format
echo 0 > config/setting/html/relativize_urls
echo "sHiTMyseLf.com" > config/site_name 

#!/bin/sh

echo 1 > config/admin/php/post/update_on_post
echo all > config/admin/php/rewrite a
echo 1 > config/admin/token/my_name_is
echo 1 > config/admin/token/title
echo 1 > config/admin/allow_self_admin_when_adminless
echo 1 > config/admin/js/loading
echo 1 > config/admin/js/translit
echo 1 > config/admin/js/fresh
echo 1 > config/admin/image/enable
echo "s * i * * y s e * f . c o m ( . h t m l )" > config/home_title 
echo 1 > config/html/clock
echo epoch > config/html/clock_format
echo 0 > config/html/relativize_urls
echo "sHiTMyseLf.com" > config/site_name 

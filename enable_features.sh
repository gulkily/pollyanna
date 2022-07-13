#!/bin/sh

echo enabling the following features:

echo javascript
echo draggable interface
echo openpgp.js
echo loading indicator
echo php
echo uploading of files
echo permissioned hashtags
echo self-admin

echo 1 > config/setting/admin/js/enable
echo 1 > config/setting/admin/php/enable
echo 1 > config/setting/admin/js/dragging
echo 1 > config/setting/admin/js/loading
echo 1 > config/setting/admin/upload/enable
echo 1 > config/setting/admin/allow_admin_permissions_tag_lookup
echo 1 > config/setting/admin/allow_self_admin_when_adminless

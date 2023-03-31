#!/bin/sh

echo "HTTP/1.1 200 OK"
echo "Content-Type: text/html"
echo ""
echo ""
echo "updating..."

cd ~/thankyou
perl -T ./default/template/perl/update.pl > /dev/null

echo "done"
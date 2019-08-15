#!/bin/bash

mkdir -p /store/upload/img
chown -R www-data:www-data /store/upload
chmod -R 700 /store/upload

exec nginx -g 'daemon off;'

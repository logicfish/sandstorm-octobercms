#!/bin/bash

# Create a bunch of folders under the clean /var that php, nginx, and mysql expect to exist
mkdir -p /var/lib/mysql
mkdir -p /var/lib/nginx
mkdir -p /var/lib/php5/sessions
mkdir -p /var/log
mkdir -p /var/log/mysql
mkdir -p /var/log/nginx
# Wipe /var/run, since pidfiles and socket files from previous launches should go away
# TODO someday: I'd prefer a tmpfs for these.
rm -rf /var/run
mkdir -p /var/run
rm -rf /var/tmp
mkdir -p /var/tmp
mkdir -p /var/run/mysqld
mkdir -p /var/run/php

# Ensure mysql tables created
HOME=/etc/mysql /usr/bin/mysql_install_db --force

# Spawn mysqld, php
HOME=/etc/mysql /usr/sbin/mysqld &
/usr/sbin/php-fpm7.0 --nodaemonize --fpm-config /etc/php/7.0/fpm/php-fpm.conf &
# Wait until mysql and php have bound their sockets, indicating readiness
while [ ! -e /var/run/mysqld/mysqld.sock ] ; do
    echo "waiting for mysql to be available at /var/run/mysqld/mysqld.sock"
    sleep .2
done
while [ ! -e /var/run/php/php7.0-fpm.sock ] ; do
    echo "waiting for php7.0-fpm to be available at /var/run/php7.0-fpm.sock"
    sleep .2
done

# Start nginx.
/usr/sbin/nginx -c /opt/app/.sandstorm/service-config/nginx.conf -g "daemon off;"

mkdir -P /var/lib/app/storage/
cp -r /opt/app/storage-orig/* /var/lib/app/storage

echo "CREATE DATABASE IF NOT EXISTS app; GRANT ALL on app.* TO 'app'@'localhost' IDENTIFIED BY 'app';" | mysql -uroot --socket /var/run/mysqld/mysqld.sock

cd /opt/app/myoctober
php artisan october:install

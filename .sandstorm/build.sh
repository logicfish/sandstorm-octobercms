#!/bin/bash
# Checks if there's a composer.json, and if so, installs/runs composer.

set -euo pipefail

cd /opt/app

#if [ -f /opt/app/composer.json ] ; then
    if [ ! -f composer.phar ] ; then
        curl -sS https://getcomposer.org/installer | php
    fi
#    php composer.phar install
#fi
#php composer.phar global require asgardcms/asgardcms-installer
##$HOME/.composer/vendor/bin/asgardcms new Blog
#php composer.phar create-project asgardcms/platform sandstorm-asgard
#cd sandstorm-asgard
#php artisan asgard:install
if [ ! -d myoctober/ ] ; then
	curl -s https://octobercms.com/api/installer | php
	php composer.phar create-project october/october myoctober
fi

#cd myoctober
#php ../composer.phar update
#php artisan october:install


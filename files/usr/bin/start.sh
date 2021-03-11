#!/bin/sh
# (C) Campbell Software Solutions 2015
set -e

# Populate "/var/www/html/include/i18n" volume with language packs
if [ ! "$(ls -A /var/www/html/include/i18n)" ]; then
    cp -r /var/www/html/include/i18n.dist/* /var/www/html/include/i18n
    chown -R www-data:www-data /var/www/html/include/i18n
fi

# Automate installation
php /usr/bin/install.php
echo Applying configuration file security
chmod 644 /var/www/html/include/ost-config.php

#Launch supervisor to manage processes
exec /usr/bin/supervisord -c /usr/bin/supervisord.conf
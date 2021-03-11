# Introduction
Docker image for running version 1.15.1 of [OSTicket](http://osticket.com/).

This image has been inspired from CampbellSoftware image [CampbellSoftwareSolutions](https://github.com/CampbellSoftwareSolutions/docker-osticket).

What is this All About?

  * Base OS: Ubuntu
  * PHP installed (with all dependencies! (zip, etc.))
  * Apache2 Installed (OSTicket with nginx is not supported (This fixes empty body email responses (by fetching) with special caracters!!!))
  * AJAX issues fixed!
  * Designed to work with a linked [MySQL](https://registry.hub.docker.com/u/library/mysql/) docker container.
  * Automates configuration file & database installation
  * Email support
  * Easy to work with nginx Proxy [JWilder](https://hub.docker.com/r/jwilder/nginx-proxy/dockerfile) (Opticional)

OSTicket is being served by [Apache2](https://httpd.apache.org/) using [PHP-FPM](http://php-fpm.org/) with PHP 7.2.
PHP7's [mail](http://php.net/manual/en/function.mail.php) function is configured to use [msmtp](http://msmtp.sourceforge.net/) to send out-going messages.

The `setup/` directory has been renamed as `setup_hidden/` and the file system permissions deny nginx access to this
location. It was not removed as the setup files are required as part of the automatic configuration during container
start.

# Quick Start
This **Quick Start**, will create 2 container linked together a MySQL and other to host OsTicket.
Is Recommended to use the `docker-compose.yml` file to create a Stack for a more controlled environment. (Use **Stack Start** tutorial (scroll down!))

```bash
docker run --name pragosa_osticket_mysql -d -e MYSQL_ROOT_PASSWORD=pragosa@tickets -e MYSQL_USER=osticket -e MYSQL_PASSWORD=pragosa@tickets -e MYSQL_DATABASE=osticket mysql:5
```

```bash
git clone https://github.com/TheGreatTDB/docker-osticket-apache2.git
```

```bash
cd docker-osticket
```

```bash
sudo docker build -t pragosa/osticket:1.15.1 .
```

```bash
docker run --name pragosa_osticket -d --link pragosa_osticket_mysql:mysql -p 8080:80 pragosa/osticket:1.15.1
```

Wait for the installation to complete then browse to your OSTicket staff control panel at `http://localhost:8080/scp/`. Login with default admin user & password:

* username: **pragosa**
* password: **Admin1**

Now configure as required. If you are intending on using this image in production, please make sure you change the
passwords above and read the rest of this documentation!

Note (1): If you want to change the environmental database variables on the OSTicket image to run, you can do it as follows.

```bash
docker run --name pragosa_osticket -d -e MYSQL_ROOT_PASSWORD=new_root_password -e MYSQL_USER=new_root_user -e MYSQL_PASSWORD=new_secret -e MYSQL_DATABASE=osticket --link osticket_mysql:mysql -p 8080:80 pragosa/osticket:1.15.1
```

Note (2): OSTicket automatically redirects `http://localhost:8080/scp` to `http://localhost/scp/`. Either serve this on port 80 or don't omit the
trailing slash after `scp/`!

# Implementation of JWilder Proxy

Serving only HTTP:
```bash
docker run -d -p 80:80 -e DEFAULT_HOST=foo.bar.com -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
```

Serving only HTTPS (SSL):
```bash
docker run -d -p 80:80 -p 443:443 -e DEFAULT_HOST=foo.bar.com -v /path/to/certs:/etc/nginx/certs -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
```

Note: Do not forget to add the environmental variables `-e VIRTUAL_HOST=foo.bar.com` and `-e VIRTUAL_PORT=9000` (default port is 80) to the container that you want to serve with proxy

# Stack Start
I added a docker-compose.yml file with a MySQL, PHPMyAdmin and the OsTicket.
If you have the **Portainer** installed you can just upload or paste the context of the `docker-compose.yml` on the Stack Web Editor.

# MySQL connection

The recommended connection method is to link your MySQL container to this image with the alias name ```mysql```. However, if you
are using an external MySQL server then you can specify the connection details using environmental variables.

OSTicket requires that the MySQL connection specifies a user with full permissions to the specified database. This is required for the automatic
 database installation.

The OSTicket configuration file is re-created from the template every time the container is started. This ensures the
MySQL connection details are always kept up to date automatically in case of any changes.

## Linked container Settings

There are no mandatory settings required when you link your MySQL container with the alias `mysql` as per the quick start example.

## External MySQL connection settings

The following environmental variables should be set when connecting to an external MySQL server.

`MYSQL_HOST`

The host name or IP address of the MySQL host to connect to. This is not required when you link a container
with the alias `mysql`. This must be provided if not using a linked container.

`MYSQL_PORT`

The TCP port number to connect to on the MySQL host. This is only required if you are not using a linked container
and also are not using the default MySQL port on your server (3306).

`MYSQL_PASSWORD`

The password for the specified user used when connecting to the MySQL server. By default will use the environmental variable
`MYSQL_PASSWORD` from the linked MySQL container if this is not explicitly specified. This must be provided if not
using a linked container.

`MYSQL_PREFIX`

The table prefix for this installation. Unlikely you will need to change this as customisable table prefixes are
designed for shared hosting with only a single MySQL database available. Defaults to 'ost_'.

`MYSQL_DATABASE`

The name of the database to connect to. Defaults to 'osticket'.

`MYSQL_USER`

The user name to use when connecting to the MySQL server. Defaults to 'osticket'.

# Mail Configuration

The image does not run a MTA. Although one could be installed quite easily, getting the setup so that external mail servers
will accept mail from your host & domain is not trivial due to anti-spam measures. This is additionally difficult to do
from ephemeral docker containers that run in a cloud where the host may change etc.

Hence this image supports OSTicket sending of mail by sending directly to designated a SMTP server.
However, you must provide the relevant SMTP settings through environmental variables before this will function.

To automatically collect email from an external IMAP or POP3 account, configure the settings for the relevant email address in
your admin control panel as normal (Admin Panel -> Emails).

## SMTP Settings

`SMTP_HOST`

The host name (or IP address) of the SMTP server to send all outgoing mail through. Defaults to 'localhost'.

`SMTP_PORT`

The TCP port to connect to on the server. Defaults to '25'. Usually one of 25, 465 or 587.

`SMTP_FROM`

The envelope from address to use when sending email (note that is not the same as the From: header). This must be
provided for sending mail to function. However, if not specified, this will default to the value of `SMTP_USER` if this is provided.

`SMTP_TLS`

Boolean (1 or 0) value indicating if TLS should be used to create a secure connection to the server. Defaults to true.

`SMTP_TLS_CERTS`

If TLS is in use, indicates file containing root certificates used to verify server certificate. Defaults to system
installed ca certificates list. This would normally only need changed if you are using your own certificate authority
or are connecting to a server with a self signed certificate.

`SMTP_USER`

The user identity to use for SMTP authentication. Specifying a value here will enable SMTP authentication. This will also
be used for the `SMTP_FROM` value if this is not explicitly specified. Defaults to no value.

`SMTP_PASSWORD`

The password associated with the user for SMTP authentication. Defaults to no value.

## IMAP/POP3 Settings

`CRON_INTERVAL`

Specifies how often (in minutes) that OSTicket cron script should be ran to check for incoming emails. Defaults to 5
minutes. Set to 0 to disable running of cron script. Note that this works in conjuction with the email check interval
specified in the admin control panel, you need to specify both to the value you'd like!

# Volumes

This image currently supports three volumes. None of these need to used if you do not require them.

`/data/upload/include/plugins`

This is the location where any OSTicket plugins, like [the core plugins](https://github.com/osTicket/core-plugins),
can be placed. Plugins are not included in this image and hence should be maintained in a separate linked Docker
container or the host filesystem.

`/data/upload/include/i18n`

This is the location where language packs can be added. There are several languages included in this image.
If you want to add / change them, you can use this volume.

`/var/log/nginx`

nginx will store it's access & error logs in this location. If you wish to expose these to automatic log
collection tools then you should mount this volume.

# Environmental Variables

`INSTALL_SECRET`

Secret string value for OST installation. A random value is generated on start-up and persisted within the container if this is not provided.

*If using in production you should specify this so that re-creating the container does not cause
your installation secret to be lost!*

`INSTALL_CONFIG`

If you require a configuration file for OSTicket with custom content then you should create one and mount it in your
container as a volume. The placeholders for the MySQL connection must be retained as these will be populated automatically
when the container starts. Set this environmental variable to the fully qualified file name of your custom configuration.
If not specified, the default OSTicket sample configuration file is used.

`INSTALL_EMAIL`

Helpdesk email account. This is placed in the configuration file as well as the DB during installation.
Defaults to 'helpdesk@example.com'

`INSTALL_URL`

The full URL of the OST ticket installation that will be set in the DB during installation. 
This should be set to match the public facing URL of your OSTicket site. 
For example: `https://help.example.com/osticket`. Defaults to `http://localhost:8080/`.

This has no effect if the database has already been installed. In this case, you should change the Helpdesk URL in 
*System Settings and Preferences* in the admin control panel.

## Database Installation Only

The remaining environmental variables can be used as a convenience to provide defaults during the automated database
installation but most of these settings can be changed through the admin panel if required. These are only used when creating
the initial database.

`INSTALL_NAME`

The name of the helpdesk to create if installing. Defaults to "My Helpdesk".

`ADMIN_FIRSTNAME`

First name of automatically created administrative user. Defaults to 'Admin'.

`ADMIN_LASTNAME`

Last name of automatically created administrative user. Defaults to 'User'.

`ADMIN_EMAIL`

Email address of automatically created administrative user. Defaults to 'admin@example.com'.

`ADMIN_USERNAME`

User name to use for automatically created administrative user. Defaults to 'pragosa'.

`ADMIN_PASSWORD`

Password to use for automatically created administrative user. Defaults to 'admin'.
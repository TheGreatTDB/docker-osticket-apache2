FROM ubuntu:20.04
# ENVIROMENT FOR OSTICKET (CHANGE VERSION CHECK https://github.com/osTicket/osTicket.git TO SEE AVAIABLE VERSIONS )
ENV OSTICKET_VERSION=1.15.1

# ENVIROMENT TO INSTALL PHP (WITHOUT ANY INPUT FROM THE KEYBOARD)
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

#INSTALL ALL DEPENDENCIES AND UTILS
RUN apt-get update && apt-get upgrade -y \
&& apt-get install apt-utils -y \
&& apt-get install cron -y \
&& apt-get install supervisor -y \
&& echo "tzdata tzdata/Areas select Europe" > /tmp/preseed.txt; \
echo "tzdata tzdata/Zones/Europe select Lisbon" >> /tmp/preseed.txt; \
debconf-set-selections /tmp/preseed.txt \
&& apt-get install -y tzdata \
&& apt-get install -y git 

# APACHE2 + PHP AND ALL PACKAGES NEEDED
RUN apt-get install -y apache2 \
&& apt-get install -y php php-fpm php-pear php-imap php-apcu php-intl php-cgi php-common php-zip php-mbstring php-net-socket php-gd php-xml-util php-mysql php-bcmath 

# INSTALL OSTICKET
RUN git clone -b v${OSTICKET_VERSION} --depth 1 https://github.com/osTicket/osTicket.git \
&& cd osTicket \
&& cp -R * /var/www/html/ \
&& mv /var/www/html/setup /var/www/html/setup_hidden \
&& mkdir /var/www/html/attachments \
&& rm -r /var/www/html/index.html

# COPY Conf to /etc/apache2/sites-enabled/
COPY files/ /

# RELOAD FILES AND RESTART SERVICE
RUN chown -R www-data:www-data /var/www/ \
&& chown www-data:www-data /var/www/ && chmod g+rx /var/www/ \
&& chmod -R 777 /usr/bin/

VOLUME ["/var/www/html/"]
EXPOSE 80
CMD ["/usr/bin/start.sh"]
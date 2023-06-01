FROM debian:buster

LABEL maintainer "nbsantos@gmail.com"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    debconf-utils && \
    echo mariadb-server mysql-server/root_password password vulnerables | debconf-set-selections && \
    echo mariadb-server mysql-server/root_password_again password vulnerables | debconf-set-selections && \
    apt-get install -y apache2 mariadb-server php php-mysqli php-gd libapache2-mod-php && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY php.ini /etc/php/7.3/apache2/php.ini

COPY dvwa /var/www/html

COPY config.inc.php /var/www/html/config/

RUN service mysql start && \
    sleep 3 && \
    mysql -uroot -pvulnerables -e "create database dvwa;create user dvwa@localhost identified by 'p@ssw0rd';grant all on dvwa.* to dvwa@localhost;flush privileges;"

RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

RUN chown www-data:www-data -R /var/www/html && \
    rm /var/www/html/index.html

EXPOSE 80

COPY start.sh /

CMD /start.sh

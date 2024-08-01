# ---------------------------------------------- Build Time Arguments --------------------------------------------------
ARG PHP_VERSION="8.2"
ARG COMPOSER_VERSION="2"

# ======================================================================================================================
#                                                 --- COMPOSER ---
# ======================================================================================================================

FROM composer:${COMPOSER_VERSION} as composer

# ======================================================================================================================
#                                               --- PHP AND APACHE ---
# ======================================================================================================================

FROM php:${PHP_VERSION}-apache as app

LABEL maintainer="cwhemmings@gmail.com"

RUN apt-get update && \
    apt-get install -y  \
        git \
        zip  \
        unzip \
        libxslt1-dev \
        libpq-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libwebp-dev \
        libxpm-dev \
        libmcrypt-dev \
        libonig-dev && \
    docker-php-ext-install xsl  \
        gd  \
        opcache  \
        calendar  \
        exif  \
        ftp  \
        gettext  \
        mysqli  \
        pcntl  \
        pdo_mysql  \
        shmop  \
        sockets  \
        sysvmsg  \
        sysvsem  \
        sysvshm && \
    apt-get remove -y  \
        libxslt1-dev  \
        icu-devtools  \
        libicu-dev  \
        libxml2-dev  \
        libzip-dev  \
        libpq-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libwebp-dev \
        libxpm-dev \
        libmcrypt-dev \
        libonig-dev && \
    rm -rf /var/lib/apt/lists/* && \
    pecl install redis && docker-php-ext-enable redis.so


ENV APACHE_DOCUMENT_ROOT /app/public
ENV APACHE_HTTP_PORT 8080
ENV APACHE_HTTPS_PORT 4433

ENV APACHE_MPM_START_SERVERS 5
ENV APACHE_MPM_MIN_SPARE_SERVERS 5
ENV APACHE_MPM_MAX_SPARE_SERVERS 10
ENV APACHE_MPM_MAX_REQUEST_WORKERS 150
ENV APACHE_MPM_MAX_CONNECTIONS_PER_CHILD 0

# prefork MPM
# StartServers: number of server processes to start
# MinSpareServers: minimum number of server processes which are kept spare
# MaxSpareServers: maximum number of server processes which are kept spare
# MaxRequestWorkers: maximum number of server processes allowed to start
# MaxConnectionsPerChild: maximum number of requests a server process serves

RUN a2dissite 000-default && a2dissite default-ssl && rm /etc/apache2/sites-available/*

COPY ./docker/apache/apache2.conf /etc/apache2/apache2.conf
COPY ./docker/apache/docker-php.conf /etc/apache2/conf-available/docker-php.conf
COPY ./docker/apache/mpm_prefork.conf /etc/apache2/mods-available/mpm_prefork.conf
COPY ./docker/apache/ports.conf /etc/apache2/ports.conf
COPY ./docker/apache/default-site.conf /etc/apache2/sites-available/default-site.conf

RUN a2enmod rewrite && a2ensite default-site

RUN mkdir "/app" && chown www-data:www-data /app

COPY --from=composer /usr/bin/composer /usr/bin/composer

USER www-data
WORKDIR /app

COPY --chown=www-data:www-data ./app /app/
EXPOSE ${APACHE_HTTP_PORT}


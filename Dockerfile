FROM php:8.3-apache

# Instala extensiones necesarias para Drupal
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    mariadb-client \
    && docker-php-ext-install pdo pdo_mysql mysqli zip gd mbstring xml

# Activa mod_rewrite para URLs amigables
RUN a2enmod rewrite

# Configuración del DocumentRoot y Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Configura los permisos para Drupal
RUN mkdir -p /var/www/html/sites/default/files \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 777 /var/www/html/sites/default/files

# Instala Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Instala Drush globalmente
RUN composer global require drush/drush && ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush

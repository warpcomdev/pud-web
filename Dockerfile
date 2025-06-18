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
    vim \
    && docker-php-ext-install pdo pdo_mysql mysqli zip gd mbstring xml \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configuración de PHP para Drupal
RUN { \
    echo 'memory_limit = 512M'; \
    echo 'upload_max_filesize = 64M'; \
    echo 'post_max_size = 64M'; \
    echo 'max_execution_time = 300'; \
    echo 'max_input_vars = 3000'; \
} > /usr/local/etc/php/conf.d/drupal.ini

# Activa mod_rewrite para URLs amigables
RUN a2enmod rewrite

# Configuración del DocumentRoot y Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Configure Apache to listen on port 8080
RUN sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf && \
    sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/g' /etc/apache2/sites-available/000-default.conf

# Expose port 8080
EXPOSE 8080

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Instala Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Instala Drush globalmente
RUN composer global require drush/drush && ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush

# Configura los permisos para Drupal
RUN mkdir -p /var/www/html/sites/default/files \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/sites/default/files

# Copia archivos de configuración de Drupal
# COPY docker/settings.php /var/www/html/sites/default/settings.php
# COPY docker/services.yml /var/www/html/sites/default/services.yml

# Configura el propietario correcto
# RUN chown www-data:www-data /var/www/html/sites/default/settings.php \
#     && chown www-data:www-data /var/www/html/sites/default/services.yml \
#     && chmod 644 /var/www/html/sites/default/settings.php \
#     && chmod 644 /var/www/html/sites/default/services.yml

# Cambia al usuario www-data para mayor seguridad
# USER www-data

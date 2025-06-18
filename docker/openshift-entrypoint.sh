#!/bin/bash
set -e

# Función para esperar a que la base de datos esté disponible
wait_for_database() {
    echo "Esperando a que la base de datos esté disponible..."
    while ! mysqladmin ping -h"${DATABASE_HOST:-db}" -P"${DATABASE_PORT:-3306}" -u"${DATABASE_USER:-drupal}" -p"${DATABASE_PASSWORD:-drupal}" --silent; do
        sleep 2
    done
    echo "Base de datos disponible"
}

# Función para importar base de datos de respaldo
import_database_backup() {
    if [ -f "/var/www/html/database_backup.sql.gz" ]; then
        echo "Importando base de datos de respaldo..."
        gunzip -c /var/www/html/database_backup.sql.gz | mysql -h"${DATABASE_HOST:-db}" -P"${DATABASE_PORT:-3306}" -u"${DATABASE_USER:-drupal}" -p"${DATABASE_PASSWORD:-drupal}" "${DATABASE_NAME:-drupal}"
        echo "Base de datos importada correctamente"
        return 0
    fi
    return 1
}

# Función para instalar Drupal si es necesario
install_drupal() {
    if [ ! -f /var/www/html/sites/default/settings.php ]; then
        echo "Instalando Drupal..."
        cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php
        chmod 644 /var/www/html/sites/default/settings.php
    fi
    
    # Verificar si Drupal ya está instalado
    if ! vendor/bin/drush status --format=json | grep -q '"bootstrap":"Successful"'; then
        echo "Drupal no está instalado. Ejecutando instalación..."
        vendor/bin/drush site:install --db-url="mysql://${DATABASE_USER:-drupal}:${DATABASE_PASSWORD:-drupal}@${DATABASE_HOST:-db}:${DATABASE_PORT:-3306}/${DATABASE_NAME:-drupal}" --account-name=admin --account-pass=admin --site-name="Drupal Site" -y
        
        # Importar configuración si existe
        if [ -d "/var/www/html/config/sync" ] && [ "$(ls -A /var/www/html/config/sync)" ]; then
            echo "Importando configuración..."
            vendor/bin/drush config:import -y
        fi
        
        # Limpiar caché
        vendor/bin/drush cr
    else
        echo "Drupal ya está instalado"
    fi
}

# Función para actualizar la base de datos
update_database() {
    echo "Actualizando base de datos..."
    vendor/bin/drush updatedb -y
    vendor/bin/drush cr
}

# Función para configurar archivos
setup_files() {
    echo "Configurando directorios de archivos..."
    mkdir -p /var/www/html/sites/default/files
    chmod -R 777 /var/www/html/sites/default/files
}

# Función principal
main() {
    echo "Iniciando Drupal en OpenShift..."
    
    # Configurar archivos
    setup_files
    
    # Esperar a la base de datos
    wait_for_database
    
    # Intentar importar base de datos de respaldo
    if import_database_backup; then
        echo "Base de datos restaurada desde respaldo"
        # Actualizar base de datos después de la restauración
        update_database
    else
        echo "No se encontró respaldo de base de datos, instalando Drupal desde cero"
        # Instalar/actualizar Drupal
        install_drupal
        update_database
    fi
    
    echo "Drupal listo. Iniciando Apache..."
    
    # Ejecutar el comando original
    exec "$@"
}

# Ejecutar función principal
main "$@" 
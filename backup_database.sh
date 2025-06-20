#!/bin/bash

# Script para generar backup de la base de datos de Drupal
# Database backup script for Drupal

# Configuración de la base de datos
DB_HOST="db"
DB_USER="drupal"
DB_PASS="drupal"
DB_NAME="drupal"

# Directorio de backups
BACKUP_DIR="backups"

# Crear directorio si no existe
mkdir -p $BACKUP_DIR

# Generar nombre del archivo con timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/drupal_backup_$TIMESTAMP.sql"

echo "Generando backup de la base de datos Drupal..."
echo "Database: $DB_NAME"
echo "Host: $DB_HOST"
echo "Archivo: $BACKUP_FILE"

# Generar backup
mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASS \
    --single-transaction \
    --routines \
    --triggers \
    --no-tablespaces \
    $DB_NAME > $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "✅ Backup completado exitosamente!"
    echo "📁 Archivo: $BACKUP_FILE"
    echo "📊 Tamaño: $(du -h $BACKUP_FILE | cut -f1)"
    
    # Comprimir backup
    echo "🗜️ Comprimiendo backup..."
    gzip $BACKUP_FILE
    echo "✅ Backup comprimido: ${BACKUP_FILE}.gz"
    echo "📊 Tamaño comprimido: $(du -h ${BACKUP_FILE}.gz | cut -f1)"
else
    echo "❌ Error al generar el backup"
    exit 1
fi

echo "🎉 Proceso completado!" 
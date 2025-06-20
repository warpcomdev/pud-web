# Backups de Base de Datos Drupal

Este directorio contiene los backups de la base de datos de Drupal.

## Archivos de Backup

- `drupal_backup_YYYYMMDD_HHMMSS.sql` - Backup completo sin comprimir
- `drupal_backup_YYYYMMDD_HHMMSS.sql.gz` - Backup comprimido con gzip

## Generar un Nuevo Backup

### Opción 1: Usar el script automático
```bash
./backup_database.sh
```

### Opción 2: Comando manual
```bash
mysqldump -h db -u drupal -pdrupal \
    --single-transaction \
    --routines \
    --triggers \
    --no-tablespaces \
    drupal > backups/drupal_backup_$(date +%Y%m%d_%H%M%S).sql
```

## Restaurar un Backup

### Desde archivo sin comprimir:
```bash
mysql -h db -u drupal -pdrupal drupal < backups/drupal_backup_YYYYMMDD_HHMMSS.sql
```

### Desde archivo comprimido:
```bash
gunzip -c backups/drupal_backup_YYYYMMDD_HHMMSS.sql.gz | mysql -h db -u drupal -pdrupal drupal
```

## Configuración de la Base de Datos

- **Host**: db
- **Usuario**: drupal
- **Contraseña**: drupal
- **Base de datos**: drupal
- **Puerto**: 3306

## Opciones de mysqldump utilizadas

- `--single-transaction`: Mantiene consistencia sin bloquear tablas
- `--routines`: Incluye procedimientos almacenados
- `--triggers`: Incluye triggers
- `--no-tablespaces`: Evita problemas de permisos con tablespaces

## Programación Automática

Para programar backups automáticos, puedes usar cron:

```bash
# Backup diario a las 2:00 AM
0 2 * * * /var/www/html/backup_database.sh

# Backup semanal los domingos a las 3:00 AM
0 3 * * 0 /var/www/html/backup_database.sh
``` 
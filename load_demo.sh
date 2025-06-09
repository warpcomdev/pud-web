#!/bin/bash
set -e

cd /var/www/html

# Descomprimir el paquete de instalación
if [ -f /workspace/theme-install/daudo_demo.zip ]; then
  echo "Descomprimiendo daudo_demo.zip..."
  unzip -qo /workspace/theme-install/daudo_demo.zip -d /var/www/html
fi

# Restaurar la base de datos
if [ -f /workspace/theme-install/database.sql.gz ]; then
  echo "Descomprimiendo y restaurando base de datos..."
  gunzip -c /workspace/theme-install/database.sql.gz | mysql -h db -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"
fi

echo "Instalación completada. Accede a http://localhost:8090"

# Despliegue en OpenShift

Este proyecto está configurado para ser desplegado automáticamente en OpenShift desde el repositorio Git.

## Opciones de Base de Datos

### **Opción 1: Base de datos vacía (recomendado para desarrollo)**
- Se crea una base de datos MySQL vacía
- Drupal se instala automáticamente
- Se importa la configuración exportada
- **Los datos de contenido NO se migran**

### **Opción 2: Migrar base de datos existente**
- Incluye el archivo `database_backup.sql.gz` en el repositorio
- Se restaura automáticamente al desplegar
- **Incluye todos los datos de contenido**

## Variables de Entorno Requeridas

Configura las siguientes variables de entorno en tu proyecto de OpenShift:

### Base de Datos
- `DATABASE_HOST`: Host de la base de datos MySQL
- `DATABASE_PORT`: Puerto de la base de datos (por defecto: 3306)
- `DATABASE_NAME`: Nombre de la base de datos
- `DATABASE_USER`: Usuario de la base de datos
- `DATABASE_PASSWORD`: Contraseña de la base de datos

### Drupal
- `DRUPAL_HASH_SALT`: Salt para Drupal (opcional, se genera automáticamente)
- `DRUPAL_PRIVATE_FILES_PATH`: Ruta para archivos privados (opcional)

## Pasos para Desplegar

### 1. Crear Proyecto en OpenShift
```bash
oc new-project drupal-project
```

### 2. Crear Base de Datos MySQL
```bash
oc new-app mysql:8.0 \
  --name=mysql \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=drupal \
  -e MYSQL_USER=drupal \
  -e MYSQL_PASSWORD=drupal
```

### 3. Desplegar Aplicación Drupal
```bash
oc new-app https://github.com/tu-usuario/tu-repositorio.git \
  --name=drupal \
  --strategy=docker \
  -e DATABASE_HOST=mysql \
  -e DATABASE_PORT=3306 \
  -e DATABASE_NAME=drupal \
  -e DATABASE_USER=drupal \
  -e DATABASE_PASSWORD=drupal
```

### 4. Exponer la Aplicación
```bash
oc expose service drupal
```

### 5. Obtener la URL
```bash
oc get route drupal
```

## Migración de Base de Datos

### Para incluir datos existentes:

1. **Exportar la base de datos actual:**
   ```bash
   mysqldump -h db -u drupal -pdrupal drupal --single-transaction --routines --triggers --no-tablespaces | gzip > database_backup.sql.gz
   ```

2. **Incluir el archivo en el repositorio:**
   ```bash
   git add database_backup.sql.gz
   git commit -m "Añadir respaldo de base de datos"
   git push
   ```

3. **El archivo se restaurará automáticamente** al desplegar en OpenShift

### Para desarrollo sin datos:
- Simplemente no incluyas el archivo `database_backup.sql.gz`
- Se instalará Drupal desde cero con la configuración exportada

## Configuración Automática

El proyecto incluye:

- **Dockerfile.openshift**: Optimizado para OpenShift
- **Scripts de entrada**: Configuración automática del entorno
- **Configuración de Drupal**: Compatible con contenedores
- **Importación automática**: La configuración se importa automáticamente
- **Restauración de BD**: Si existe `database_backup.sql.gz`, se restaura automáticamente

## Estructura de Archivos

```
├── Dockerfile.openshift          # Dockerfile para OpenShift
├── docker/
│   └── openshift-entrypoint.sh   # Script de inicio
├── .openshift/
│   └── action_hooks/             # Scripts de OpenShift
├── config/
│   └── sync/                     # Configuración exportada
├── database_backup.sql.gz        # Respaldo de BD (opcional)
└── sites/default/
    └── settings.php              # Configuración de Drupal
```

## Notas Importantes

1. **Puerto 8080**: La aplicación se ejecuta en el puerto 8080 (requerido por OpenShift)
2. **Usuario no-root**: El contenedor se ejecuta como usuario no-root por seguridad
3. **Configuración automática**: Drupal se instala y configura automáticamente
4. **Persistencia**: Los archivos se almacenan en volúmenes persistentes
5. **Base de datos**: Se restaura automáticamente si existe el respaldo

## Solución de Problemas

### Error de conexión a la base de datos
Verifica que las variables de entorno estén configuradas correctamente:
```bash
oc get dc drupal -o yaml
```

### Error de permisos
Verifica que los directorios tengan los permisos correctos:
```bash
oc rsh dc/drupal ls -la sites/default/files
```

### Logs de la aplicación
```bash
oc logs dc/drupal
```

### Verificar restauración de base de datos
```bash
oc rsh dc/drupal ls -la database_backup.sql.gz
``` 
<?php

/**
 * @file
 * Drupal site-specific configuration file.
 */

// Database configuration
$databases['default']['default'] = [
  'database' => getenv('DRUPAL_DB_NAME') ?: 'drupal',
  'username' => getenv('DRUPAL_DB_USER') ?: 'drupal',
  'password' => getenv('DRUPAL_DB_PASSWORD') ?: 'drupal',
  'prefix' => '',
  'host' => getenv('DRUPAL_DB_HOST') ?: 'localhost',
  'port' => getenv('DRUPAL_DB_PORT') ?: '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
];

// Hash salt
$settings['hash_salt'] = getenv('DRUPAL_HASH_SALT') ?: 'your-hash-salt-here';

// Trusted host patterns
$settings['trusted_host_patterns'] = [
  '^localhost$',
  '^.*\.docker\.internal$',
  '^.*\.local$',
];

// File system settings
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = 'sites/default/files/private';

// Cache settings
$settings['cache']['bins']['render'] = 'cache.backend.null';
$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
$settings['cache']['bins']['page'] = 'cache.backend.null';

// Development settings
if (getenv('DRUPAL_ENVIRONMENT') === 'development') {
  $settings['cache']['bins']['render'] = 'cache.backend.null';
  $settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
  $settings['cache']['bins']['page'] = 'cache.backend.null';
  $settings['cache']['bins']['discovery'] = 'cache.backend.null';
  $settings['cache']['bins']['bootstrap'] = 'cache.backend.null';
  $settings['cache']['bins']['data'] = 'cache.backend.null';
  $settings['cache']['bins']['entity'] = 'cache.backend.null';
  $settings['cache']['bins']['menu'] = 'cache.backend.null';
  $settings['cache']['bins']['toolbar'] = 'cache.backend.null';
  $settings['cache']['bins']['update'] = 'cache.backend.null';
  $settings['cache']['bins']['discovery_migration'] = 'cache.backend.null';
  $settings['cache']['bins']['migrate'] = 'cache.backend.null';
  $settings['cache']['bins']['default'] = 'cache.backend.null';
}

// Error reporting
if (getenv('DRUPAL_ENVIRONMENT') === 'development') {
  $config['system.logging']['error_level'] = 'verbose';
} else {
  $config['system.logging']['error_level'] = 'hide';
}

// Performance settings
$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/default/services.yml'; 
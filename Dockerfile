# Imagen base de PHP con Apache
FROM php:8.2-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    nodejs \
    npm \
    ca-certificates \
    openssl

# Limpiar caché de apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Actualizar certificados SSL (crítico para Aiven)
RUN update-ca-certificates

# Instalar extensiones de PHP
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Habilitar mod_rewrite de Apache
RUN a2enmod rewrite

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos del proyecto
COPY . /var/www/html

# Instalar dependencias de PHP (sin dev)
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# Instalar dependencias de JavaScript
RUN npm install --legacy-peer-deps

# Compilar assets con Vite
RUN npm run build

# Establecer permisos correctos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Configurar Apache para que apunte a /public
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Configurar AllowOverride para .htaccess
RUN echo '<Directory /var/www/html/public>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' >> /etc/apache2/sites-available/000-default.conf

# Limpiar cache de Laravel
RUN php artisan optimize:clear || true

# Exponer puerto 80
EXPOSE 80

# Comando de inicio (ejecuta migraciones y luego inicia Apache)
CMD php artisan migrate --force && apache2-foreground
```

**Guarda el archivo.**

---

### PASO 4: Crear archivo `.dockerignore`

Crea `.dockerignore` en la raíz con este contenido:
```
.git
.env
.env.example
node_modules
vendor
storage/logs/*
storage/framework/cache/*
storage/framework/sessions/*
storage/framework/views/*
bootstrap/cache/*
.vscode
.idea
*.log
.DS_Store
Thumbs.db
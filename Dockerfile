# Imagen oficial PHP con FPM (mejor que cli para producción)
FROM php:8.2-cli

# Instalar dependencias del sistema y Node.js correctamente
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    zip \
    libzip-dev \
    libpng-dev \
    libxml2-dev \
    libonig-dev \
    gnupg

# Instalar Node.js 18 (estable)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Instalar extensiones PHP necesarias para Laravel
RUN docker-php-ext-install \
    pdo_mysql \
    mbstring \
    zip \
    exif \
    pcntl \
    bcmath

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Crear directorio app
WORKDIR /var/www/app

# Copiar archivos del proyecto
COPY . .

# Instalar dependencias PHP
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Instalar dependencias frontend
RUN npm install

# Compilar frontend (Inertia / Vue)
RUN npm run build

# Permisos necesarios
RUN chmod -R 777 storage bootstrap/cache

# Limpiar cache
RUN php artisan config:clear
RUN php artisan route:clear
RUN php artisan view:clear

# Puerto de Render
EXPOSE 10000

# Comando de inicio
CMD php artisan serve --host=0.0.0.0 --port=10000
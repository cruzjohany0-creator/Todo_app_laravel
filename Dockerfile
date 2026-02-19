# Usar imagen oficial PHP
FROM php:8.2-cli

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    zip \
    libzip-dev \
    libpng-dev \
    libxml2-dev \
    libonig-dev \
    nodejs \
    npm

# Instalar extensiones necesarias de PHP
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Crear carpeta de la aplicación
WORKDIR /var/www/app

# Copiar todos los archivos
COPY . .

# Instalar dependencias Laravel
RUN composer install --no-dev --optimize-autoloader

# Instalar dependencias frontend (Inertia + Vue)
RUN npm install
RUN npm run build

# Generar APP_KEY automáticamente
RUN php artisan key:generate --force

# Limpiar cache
RUN php artisan config:clear
RUN php artisan route:clear
RUN php artisan view:clear

# Puerto que usa Render
EXPOSE 10000

# Comando de inicio
CMD php artisan serve --host=0.0.0.0 --port=10000
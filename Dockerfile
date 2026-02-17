# Usar imagen de PHP con Apache
FROM php:8.2-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libpng-dev libonig-dev libxml2-dev zip unzip git curl nodejs npm

# Instalar extensiones de PHP para MySQL
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Habilitar mod_rewrite para Laravel
RUN a2enmod rewrite

# Directorio de trabajo
WORKDIR /var/www/html
COPY . .

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev --optimize-autoloader

# Instalar dependencias de JS y compilar Vite (con el flag para evitar el error que tenías)
RUN npm install --legacy-peer-deps
RUN npm run build

# Permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Configurar Apache para apuntar a /public
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

EXPOSE 80
CMD ["apache2-foreground"]
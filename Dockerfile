FROM php:8.2-cli

RUN apt-get update && apt-get install -y \
    git unzip curl zip \
    libzip-dev libpng-dev libxml2-dev libonig-dev \
    gnupg ca-certificates

# instalar node 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/app

COPY composer.json composer.lock ./

RUN composer install --no-dev --optimize-autoloader --no-interaction

COPY . .

# SOLUCION ERROR ERESOLVE
RUN npm install --legacy-peer-deps

RUN npm run build

RUN cp .env.example .env || true

RUN php artisan key:generate --force || true

RUN chmod -R 777 storage bootstrap/cache

EXPOSE 10000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
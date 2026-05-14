FROM php:8.4-fpm

WORKDIR /var/www/fe_sehadir

RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    libzip-dev \
    libcurl4-openssl-dev \
    pkg-config \
    zip \
    unzip \
    libz-dev \
    libssl-dev \
    procps \
    net-tools

RUN docker-php-ext-install pdo_pgsql pgsql mbstring exif pcntl bcmath gd zip
RUN pecl install redis \
    && docker-php-ext-enable redis

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY composer.json composer.lock artisan ./

COPY . .

RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader

RUN composer dump-autoload --optimize --classmap-authoritative
RUN php artisan package:discover --ansi

RUN chown -R www-data:www-data /var/www/fe_sehadir/storage /var/www/fe_sehadir/bootstrap/cache
RUN sed -i 's|listen = .*|listen = 9000|' /usr/local/etc/php-fpm.d/www.conf || echo "listen = 9000" >> /usr/local/etc/php-fpm.d/zz-docker.conf

EXPOSE 9000

CMD ["php-fpm"]
# syntax=docker/dockerfile:1
FROM php:8.3-cli-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq-dev libonig-dev libxml2-dev unzip git \
    && docker-php-ext-install pdo_pgsql mbstring dom \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
WORKDIR /var/www/html
# Keep host dependencies, local secrets and compiled configuration out of layers.
RUN --mount=from=api_source,target=/api-source \
    tar -C /api-source --exclude='./.git' --exclude='./.env' --exclude='./.env.*' \
        --exclude='./vendor' --exclude='./node_modules' --exclude='./bootstrap/cache/*.php' \
        --exclude='./storage/logs/*' -cf - . | tar -xf -
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader --no-scripts \
    && mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs /var/lib/library/covers \
    && chown -R www-data:www-data storage bootstrap/cache /var/lib/library/covers

USER www-data
EXPOSE 8000
# Schema changes and initial admin creation remain the API's responsibility.
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]

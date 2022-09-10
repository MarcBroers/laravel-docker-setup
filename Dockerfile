
# ----------------------
# The FPM base container
# ----------------------
FROM php:8.1-fpm as dev
RUN apt update && apt install -y zlib1g-dev libpng-dev
RUN docker-php-ext-install mysqli pdo pdo_mysql
WORKDIR /app

# ----------------------
# Composer install step
# ----------------------
FROM composer:2.1.8 as build
WORKDIR /app
COPY composer.* ./
COPY nova-components nova-components/
COPY auth.json ./auth.json
COPY database/ database/
RUN composer install --ignore-platform-reqs --no-scripts

# ----------------------
# npm install step
# ----------------------
FROM node:12-alpine as node
WORKDIR /app
COPY *.json *.mix.js tailwind.config.js /app/
COPY resources /app/resources
RUN mkdir -p /app/public \
    && npm install && npm run production

# # ----------------------
# # The FPM production container
# # ----------------------
FROM dev
RUN apt-get update -y \
    && apt-get install -y nginx
COPY ./docker/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./docker/nginx.conf /etc/nginx/nginx.conf
COPY . /app
COPY --from=build /app/vendor/ /app/vendor/
COPY --from=node /app/public/js/ /app/public/js/
COPY --from=node /app/public/css/ /app/public/css/
COPY --from=node /app/mix-manifest.json /app/public/mix-manifest.json
RUN chmod -R 777 /app/storage
COPY --chown=www-data:www-data . /app
COPY /docker/entrypoint.sh /etc/entrypoint.sh
WORKDIR /app
EXPOSE 80
ENTRYPOINT ["sh", "/etc/entrypoint.sh"]

# Utiliser l'image de base webdevops/php-nginx
FROM webdevops/php-nginx:8.2

# Allow composer to run as superuser
ENV COMPOSER_ALLOW_SUPERUSER=1

# Définir le répertoire de travail
WORKDIR /var/www/html

# Copier les fichiers du projet Laravel dans le conteneur
COPY . .

# Copier la configuration Nginx personnalisée
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Copier le fichier d'environnement 
COPY .env.example .env

# Create necessary set permissions. "application:application" is the user used by webdevods/php-nginx image
RUN mkdir -p /var/www/html/storage/logs \
    && mkdir -p /var/log/nginx \
    && chown -R application:application /var/log/nginx

# Remove composer.lock if exist  
RUN rm -f composer.lock

# Installer les dépendances PHP
RUN composer install --no-dev --optimize-autoloader



COPY entrypoint.sh /usr/local/bin/
RUN apt-get update \
    && apt-get install -y dos2unix \
    && apt-get clean \
    && dos2unix /usr/local/bin/entrypoint.sh \ 
    && chmod +x /usr/local/bin/entrypoint.sh

# Définir le point d'entrée
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["supervisord"]
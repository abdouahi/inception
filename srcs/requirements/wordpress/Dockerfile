FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        php8.2-fpm \ #fastcgi
        php8.2-mysql \ #link database
        php8.2-curl \ #https requests
        php8.2-gd \ # traitement d'images
        php8.2-mbstring \ # multibyte caractères
        php8.2-xml \ #data format support
        php8.2-zip \ #ZIP archives
        mariadb-client \ #tconnecta m3a database server
        curl \
        ca-certificates \
        tar \ #archives
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/wp_setup.sh /usr/local/bin/wp_setup.sh

RUN chmod +x /usr/local/bin/wp_setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp_setup.sh"]

# Base Image
FROM php:7.1-fpm-alpine

# Declare ARGS and ENV Variables
ARG URL
ENV URL $URL
ENV PROCESSMAKER_VERSION 3.3.0-RE-1.7

# Extra
LABEL version="${PROCESSMAKER_VERSION}"
LABEL description="ProcessMaker Server ${PROCESSMAKER_VERSION} Docker Container for GLPI."
LABEL maintainer="Wolvverine <wolvverinepld [at] gmail [dot] com>"

# Initial steps
RUN set -ex ;\
	rm -rf /var/cache/apk/* /tmp/* /var/tmp/* ;\
	apk update --no-cache;\
	apk add --no-cache \
	bash \
	tzdata \
	wget \
	vim \
	nano \
	nginx \
	unzip \
	freetds \
	ca-certificates \
	libgd \
	libldap \
	libmcrypt \
	libxpm \
	supervisor \
	mysql-client \
	;\
	apk add --no-cache --virtual .build-deps \
	$PHPIZE_DEPS \
	autoconf \
	bzip2-dev \
	coreutils \
	curl-dev \
	freetype-dev \
	icu-dev \
	imagemagick-dev \
	libevent-dev \
	libjpeg-turbo-dev \
	libmcrypt-dev \
	libpng-dev \
	libxml2-dev \
	libzip-dev \
	openldap-dev \
	pcre-dev \
	libxpm-dev \
	libwebp-dev \
	zlib-dev \
	;\
	docker-php-source extract ; \
	docker-php-ext-configure gd --with-freetype-dir=/usr/ --with-png-dir=/usr/ --with-jpeg-dir=/usr/ --with-xpm-dir=/usr/; \
	docker-php-ext-configure ldap ;\
	docker-php-ext-install gd ;\
	docker-php-ext-install ldap ;\
	docker-php-ext-install soap ;\
	docker-php-ext-install xml ;\
	docker-php-ext-install pdo_mysql ;\
	docker-php-ext-install mysqli ;\
	docker-php-ext-install mcrypt ;\
	docker-php-ext-install curl \
	;\
	docker-php-source delete \
	; \
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
		| tr ',' '\n' \
		| sort -u \
		| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk del .build-deps ; \
	wget -O "/tmp/processmaker-server-${PROCESSMAKER_VERSION}.zip" \
	"https://github.com/tomolimo/processmaker-server/releases/download/3.3.0-RE-1.7/processmaker-server-${PROCESSMAKER_VERSION}.zip" \
	&& unzip "/tmp/processmaker-server-${PROCESSMAKER_VERSION}.zip" -d /opt/ ;\
	rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

#	&& mv /etc/hosts ~/hosts.new \
#	&& sed -i "/127.0.0.1/c\127.0.0.1 localhost localhost.localdomain `hostname`" /etc/hosts \
#	&& mv -f ~/hosts.new /etc/hosts

# Configuration files
RUN rm -f /usr/local/etc/php-fpm.d/*
COPY processmaker-fpm.conf /usr/local/etc/php-fpm.d/zz-processmaker-fpm.conf
RUN rm /etc/nginx/nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf
RUN rm -f /etc/nginx/conf.d/default.conf
COPY processmaker.conf /etc/nginx/conf.d/default.conf

#chmod -R g=rX,o=--- /opt/processmaker-server/* \
RUN mkdir -p /var/tmp/nginx /var/log/nginx \
	&& chown -R nginx:nginx /var/log/nginx /var/lib/nginx \
	&& mkdir -p /var/log/php-fpm \
	&& chown -R nginx:nginx /var/log/php-fpm \
	&& mkdir -p /opt/processmaker-server/Backup \
	&& chown -R nginx:nginx /opt/processmaker-server/Backup

# TODO writable files - to volume - !! data and code
RUN chown -R nginx:nginx /opt/processmaker-server/bootstrap/cache \
/opt/processmaker-server/workflow/engine/config/ \
/opt/processmaker-server/workflow/engine/content/languages/ \
/opt/processmaker-server/workflow/engine/plugins/ \
/opt/processmaker-server/workflow/engine/xmlform/ \
/opt/processmaker-server/workflow/engine/js/labels/ \
/opt/processmaker-server/workflow/public_html/translations/ \
/opt/processmaker-server/workflow/public_html/index.html \
/opt/processmaker-server/shared/

# NGINX Ports
EXPOSE 8090

WORKDIR "/opt/processmaker-server/workflow/engine"
VOLUME "/opt/processmaker-server/Backup"

# Docker entrypoint
COPY supervisord.conf /etc/supervisord.conf
COPY docker-entrypoint.sh /bin/
RUN chmod a+x /bin/docker-entrypoint.sh
ENTRYPOINT ["/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "--configuration", "/etc/supervisord.conf"]
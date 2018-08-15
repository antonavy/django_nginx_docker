# FROM python:3.7.0-stretch
FROM ubuntu:18.04
# FROM tiangolo/uwsgi-nginx:python3.6

LABEL maintainer="Anton Kalashnikov <antonka@yandex-team.ru>"

ENV DEBIAN_FRONTEND noninteractive

# Install app-utils
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils

# Install locales
RUN apt-get install -y locales

# Setup locale
RUN sed -i -e 's/# ru_RU.UTF-8 en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen ru_RU.UTF-8 en_US.UTF-8 && \
    dpkg-reconfigure --frontend=noninteractive locales
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install packages
RUN apt-get install -y \
	curl \
	dnsutils \
	netcat \
	ssh \
	telnet \
	vim \
    nginx \
    supervisor \
	gcc \
    tmux \
	python3 \
    python3-dev \
    python3-setuptools \
    python3-pip \
	mysql-client default-libmysqlclient-dev \
	postgresql-client libpq-dev \
	build-essential gettext \
	sqlite3 \
	net-tools \
    && pip3 install -U pip setuptools \
	&& rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt /app/
WORKDIR /app/

# Configure everything for python
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt

# Copy everything else
COPY . /app/

# Nginx settings
COPY supervisor-app.conf /etc/supervisor/conf.d/

RUN ln -sf /app/exp_app_nginx.conf /etc/nginx/sites-enabled/
RUN ln -sf /app/exp_app_nginx.conf /etc/nginx/sites-available/

ENV NGINX_MAX_UPLOAD 0
ENV STATIC_INDEX 0

# Global envs
ENV PYTHONPATH=/app

# Copy start.sh script that will start supervisor
# COPY start.sh /start.sh
# RUN chmod 755 /start.sh

# # Forward uwsgi logs to the docker log collector
# RUN ln -sf /dev/stdout /var/log/uwsgi/djangoapp.log \
# && ln -sf /dev/stdout /var/log/uwsgi/emperor.log

# Run the start script, it will start Supervisor, which in turn will start Nginx and uWSGI
# CMD ["/start.sh"]

# # Start uWSGI on container startup
# CMD /usr/local/bin/uwsgi --emperor files_uwsgi --gid www-data --logto /var/log/uwsgi/emperor.log

# EXPOSE 80

CMD ["supervisord", "-n"]

ENV DEBIAN_FRONTEND teletype

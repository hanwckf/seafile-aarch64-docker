#!/bin/sh

set -x

export DEBIAN_FRONTEND=noninteractive

if [ -z "$TRAVIS" ]; then
	sed -i 's#http://ports.ubuntu.com#http://mirrors.huaweicloud.com#' /etc/apt/sources.list
fi

apt update -y -q --fix-missing && apt upgrade -y -q
apt install -y -q vim htop net-tools psmisc openssl memcached \
	wget curl git tzdata nginx libmemcached11 libtiff5 \
	python3 python3-pip python3-setuptools zlib1g libwebp6 \
	libwebpdemux2 libwebpmux3 sqlite3 libfreetype6

apt clean

ln -sf /usr/bin/python3 /usr/bin/python

if [ -z "$TRAVIS" ]; then
	python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple pip -U
	python3 -m pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
else
	python3 -m pip install --upgrade pip
fi

python3 -m pip install click termcolor colorlog pymysql jinja2 sqlalchemy

rm -r /root/.cache/pip

mkdir -p /etc/my_init.d && \
	rm -f /etc/my_init.d/* && \
	cp /scripts/create_data_links.sh /etc/my_init.d/01_create_data_links.sh

mkdir -p /etc/service/nginx && \
	rm -f /etc/nginx/sites-enabled/* /etc/nginx/conf.d/* && \
	mv /services/nginx.conf /etc/nginx/nginx.conf && \
	mv /services/nginx.sh /etc/service/nginx/run

mkdir -p /etc/service/memcached && \
	mv /services/memcached.sh /etc/service/memcached/run

find /opt/seafile/ \( -name "liblber-*" -o -name "libldap-*" -o -name "libldap_r*" -o -name "libsasl2.so*" \) -delete


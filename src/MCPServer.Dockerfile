FROM python:2.7-stretch

ENV DEBIAN_FRONTEND noninteractive
ENV DJANGO_SETTINGS_MODULE settings.common
ENV PYTHONPATH /src/MCPServer/lib/:/src/archivematicaCommon/lib/:/src/dashboard/src/
ENV PYTHONUNBUFFERED 1

RUN set -ex \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		gettext \
		default-libmysqlclient-dev \
		libldap2-dev \
		libsasl2-dev \
		locales \
		locales-all \
		sudo \
	&& rm -rf /var/lib/apt/lists/*

# Set the locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


COPY archivematicaCommon/requirements/ /src/archivematicaCommon/requirements/
COPY dashboard/src/requirements/ /src/dashboard/src/requirements/
COPY MCPServer/requirements/ /src/MCPServer/requirements/
RUN pip install -r /src/archivematicaCommon/requirements/production.txt -r /src/archivematicaCommon/requirements/dev.txt
RUN pip install -r /src/dashboard/src/requirements/production.txt -r /src/dashboard/src/requirements/dev.txt
RUN pip install -r /src/MCPServer/requirements/production.txt -r /src/MCPServer/requirements/dev.txt

COPY archivematicaCommon/ /src/archivematicaCommon/
COPY dashboard/ /src/dashboard/
COPY MCPServer/ /src/MCPServer/
COPY entrypoint-server.sh /entrypoint-server.sh

RUN set -ex \
	&& groupadd --gid 333 --system archivematica \
	&& useradd --uid 333 --gid 333 --system archivematica

RUN set -ex \
	&& mkdir -p /var/archivematica/sharedDirectory \
	&& chown -R archivematica:archivematica /var/archivematica

RUN apt update && apt-get -y install fuse
RUN pip install xattr
RUN curl --output /tmp/oneclient_20.2.1.deb http://packages.devel.onedata.org/apt/ubuntu/2002/pool/main/o/oneclient/oneclient_20.02.0.beta4.100.g85db903-1~bionic_amd64.deb && \
    apt install /tmp/oneclient_20.2.1.deb && \
    rm /tmp/oneclient_20.2.1.deb

RUN adduser archivematica sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN oneclient -h

USER archivematica

ENV ONECLIENT_ACCESS_TOKEN=
ENV ONECLIENT_PROVIDER_HOST=
ENV ONECLIENT_SPACE=
ENV ONECLIENT_OPTS=
ENV ONECLIENT_MOUNTPOINT=/tmp/oneclient-mnt

RUN mkdir $ONECLIENT_MOUNTPOINT

ENTRYPOINT ["bash", "/entrypoint-server.sh"]

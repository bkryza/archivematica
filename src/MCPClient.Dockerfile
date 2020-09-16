FROM artefactual/archivematica-mcp-client-base:20200210.01.0461aae

ENV DJANGO_SETTINGS_MODULE settings.common
ENV PYTHONPATH /src/MCPClient/lib/:/src/archivematicaCommon/lib/:/src/dashboard/src/
ENV ARCHIVEMATICA_MCPCLIENT_MCPCLIENT_ARCHIVEMATICACLIENTMODULES /src/MCPClient/lib/archivematicaClientModules
ENV ARCHIVEMATICA_MCPCLIENT_MCPCLIENT_CLIENTASSETSDIRECTORY /src/MCPClient/lib/assets/
ENV ARCHIVEMATICA_MCPCLIENT_MCPCLIENT_CLIENTSCRIPTSDIRECTORY /src/MCPClient/lib/clientScripts/

COPY archivematicaCommon/requirements/ /src/archivematicaCommon/requirements/
COPY dashboard/src/requirements/ /src/dashboard/src/requirements/
COPY MCPClient/requirements/ /src/MCPClient/requirements/
RUN pip install -r /src/archivematicaCommon/requirements/production.txt -r /src/archivematicaCommon/requirements/dev.txt
RUN pip install -r /src/dashboard/src/requirements/production.txt -r /src/dashboard/src/requirements/dev.txt
RUN pip install -r /src/MCPClient/requirements/production.txt -r /src/MCPClient/requirements/dev.txt

COPY archivematicaCommon/ /src/archivematicaCommon/
COPY dashboard/ /src/dashboard/
COPY MCPClient/ /src/MCPClient/
COPY entrypoint-client.sh /entrypoint-client.sh

# Some scripts in archivematica-fpr-admin executed by MCPClient rely on certain
# files being available in this image (e.g. see https://git.io/vA1wF).
COPY archivematicaCommon/lib/externals/fido/ /usr/lib/archivematica/archivematicaCommon/externals/fido/
COPY archivematicaCommon/lib/externals/fiwalk_plugins/ /usr/lib/archivematica/archivematicaCommon/externals/fiwalk_plugins/

RUN apt update && apt-get -y install fuse sudo
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

RUN mkdir /tmp/oneclient-mnt

ENTRYPOINT ["bash", "/entrypoint-client.sh"]

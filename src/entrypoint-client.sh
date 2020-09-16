#!/bin/bash

sudo oneclient --enable-archivematica --space $ONECLIENT_SPACE -t $ONECLIENT_ACCESS_TOKEN -H $ONECLIENT_PROVIDER_HOST -o allow_other $ONECLIENT_OPTS $ONECLIENT_MOUNTPOINT

/src/MCPClient/lib/archivematicaClient.py

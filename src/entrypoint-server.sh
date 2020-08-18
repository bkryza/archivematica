#!/bin/bash

sudo oneclient --space $ONECLIENT_SPACE -t $ONECLIENT_ACCESS_TOKEN -H $ONECLIENT_PROVIDER_HOST -o allow_other $ONECLIENT_OPTS $ONECLIENT_MOUNTPOINT

/src/MCPServer/lib/archivematicaMCP.py

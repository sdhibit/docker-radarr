#! /bin/sh

# Start Radarr
/sbin/su-exec radarr /usr/bin/mono /opt/radarr/Radarr.exe \
   --no-browser \
   -data=/config
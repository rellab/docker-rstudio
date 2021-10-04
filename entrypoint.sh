#!/bin/sh

echo "$RSTUDIO_USER:$RSTUDIO_PASSWORD" | chpasswd

if [ $RSTUDIO_GRANT_SUDO = "yes" ]; then
  echo "rstudio ALL=(ALL) ALL" >> /etc/sudoers.d/rstudio
elif [ $RSTUDIO_GRANT_SUDO = "nopass" ]; then
  echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/rstudio
fi

## Rstudio
/usr/lib/rstudio-server/bin/rserver --server-daemonize=0 --www-port $RSTUDIO_PORT

#!/bin/sh

echo "$RSTUDIO_USER:$RSTUDIO_PASSWORD" | chpasswd

if [ -n "$RSTUDIO_GRANT_SUDO" ]; then
  if [ "$RSTUDIO_GRANT_SUDO" = "yes" ]; then
    echo "$RSTUDIO_USER ALL=(ALL) ALL" >> /etc/sudoers.d/$RSTUDIO_USER
  elif [ "$RSTUDIO_GRANT_SUDO" = "nopass" ]; then
    echo "$RSTUDIO_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$RSTUDIO_USER
  fi
fi

exec /usr/lib/rstudio-server/bin/rserver --server-daemonize=0 --www-port "$RSTUDIO_PORT" --www-address=${RSTUDIO_BIND}

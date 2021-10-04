#!/bin/sh

groupadd -f -g $RSTUDIO_GID $RSTUDIO_GROUP || exit 1
if [ $RSTUDIO_PASSWORD = "no" ]; then
  useradd -d $RSTUDIO_HOME -u $RSTUDIO_UID -g $RSTUDIO_GID -s /bin/bash $RSTUDIO_USER || exit 1
else
  useradd -d $RSTUDIO_HOME -u $RSTUDIO_UID -g $RSTUDIO_GID -s /bin/bash -p `echo "$RSTUDIO_PASSWORD" | mkpasswd -s -m sha-512` $RSTUDIO_USER || exit 1
fi

if [ $RSTUDIO_GRANT_SUDO = "yes" ]; then
  echo "$RSTUDIO_USER ALL=(ALL) ALL" >> /etc/sudoers.d/$RSTUDIO_USER
elif [ $RSTUDIO_GRANT_SUDO = "nopass" ]; then
  echo "$RSTUDIO_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$RSTUDIO_USER
fi

mkdir -p $RSTUDIO_HOME
chown $RSTUDIO_USER:$RSTUDIO_GROUP $RSTUDIO_HOME
su - $RSTUDIO_USER -c "cp -n -r --preserve=mode /etc/skel/. $RSTUDIO_HOME"

## Rstudio
/usr/lib/rstudio-server/bin/rserver --server-daemonize=0 --www-port $RSTUDIO_PORT

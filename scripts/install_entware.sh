#!/bin/sh

DATA=/usr/data
APPETC=/usr/apps/etc
INITD=$APPETC/init.d
OPT_FILE_NAME=entware_opt_mount.img
ENTWARE_PATH=$INITD/S48entware

if command -v opkg >/dev/null 2>&1; then
  echo "OPKG is already installed!"
  exit 1
fi

if [ -f $DATA/$OPT_FILE_NAME ]; then
  echo "Existing $DATA/$OPT_FILE_NAME file found. Skipping creation."
else
  # Create 500mb image
  echo "Creating /opt image..."
  dd if=/dev/zero of=$DATA/$OPT_FILE_NAME bs=1M count=500
  mkfs.ext4 -F $DATA/$OPT_FILE_NAME
fi

if [ ! -f $ENTWARE_PATH ]; then
  echo "Adding entware script to $INITD"
  {
    echo '#!/bin/sh'
    echo '# Creality Helper Script — persistent Entware /opt (must run before S50*).'
    echo "ENTWARE_IMG=\"$ENTWARE_OPT_MOUNT\""
    echo 'mkdir -p /opt'
    echo 'if ! grep -q " /opt " /proc/mounts; then'
    echo '  mount -o loop "$ENTWARE_IMG" /opt || exit 1'
    echo 'fi'
    echo 'if [ -f /opt/etc/init.d/rc.unslung ]; then'
    echo '  /opt/etc/init.d/rc.unslung start'
    echo 'fi'
    echo 'mkdir -p /usr/libexec'
    echo 'if [ ! -e /usr/libexec/sftp-server ] && [ -f /opt/libexec/sftp-server ]; then'
    echo '  ln -sf /opt/libexec/sftp-server /usr/libexec/sftp-server'
    echo 'fi'
    echo 'if ! grep -qF "/opt/bin:/opt/sbin" /etc/profile 2>/dev/null; then'
    echo '  echo '"'"'export PATH=/opt/bin:/opt/sbin:$PATH'"'"' >> /etc/profile'
    echo 'fi'
  } > "$ENTWARE_PATH"
  chmod +x $ENTWARE_PATH
fi

#Manually mount for now
mount -o loop $DATA/$OPT_FILE_NAME /opt

#Install entware
wget -O - http://bin.entware.net/mipselsf-k3.4/installer/generic.sh | sh
export PATH=/opt/bin:/opt/sbin:$PATH

echo "Installing SFTP Server (for SCP)"
opkg install openssh-sftp-server
echo "Installing git"
opkg install git git-http
echo "Finished!"

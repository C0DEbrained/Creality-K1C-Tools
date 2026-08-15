#!/bin/sh

DATA=/usr/data
APPETC=/usr/apps/etc
INITD=$APPETC/init.d
OPT_FILE_NAME=entware_opt_mount.img

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

if [ ! -f $INITD/S60entware ]; then
  echo "Adding entware script to $INITD"
  cat << EOF > $INITD/S60opt_mount
  #!/bin/sh
  mkdir -p /opt
  mount -o loop $DATA/$OPT_FILE_NAME /opt

  # Start Entware services (if any are installed like SSH, lighttpd, etc.)
  if [ -f /opt/etc/init.d/rc.unslung ]; then
      /opt/etc/init.d/rc.unslung start
  fi

  # Inject Entware into the system PATH globally for all users
  echo 'export PATH=/opt/bin:/opt/sbin:$PATH' >> /etc/profile
EOF
  chmod +x $INITD/S60opt_mount
fi

#Manually mount for now
mount -o loop $DATA/$OPT_FILE_NAME /opt

#Install entware
wget -O - http://bin.entware.net/mipselsf-k3.4/installer/generic.sh | sh
export PATH=/opt/bin:/opt/sbin:$PATH

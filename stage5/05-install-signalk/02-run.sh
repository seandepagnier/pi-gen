#!/bin/bash -e

#install sk
on_chroot << EOF
npm install -g --unsafe-perm signalk-server
EOF

#config sk
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.signalk"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.signalk/plugin-config-data"
install -m 644 -o 1000 -g 1000 files/.npmrc		"${ROOTFS_DIR}/home/pi/.signalk/"
install -m 644 -o 1000 -g 1000 files/package.json		"${ROOTFS_DIR}/home/pi/.signalk/"
install -m 644 -o 1000 -g 1000 files/settings.json		"${ROOTFS_DIR}/home/pi/.signalk/"
install -m 775 -o 1000 -g 1000 files/signalk-server		"${ROOTFS_DIR}/home/pi/.signalk/"
install -m 644 -o 1000 -g 1000 files/defaults.json		"${ROOTFS_DIR}/home/pi/.signalk/"
uuid=$(uuid)
cat > "${ROOTFS_DIR}/home/pi/.signalk/defaults.json" <<EOL
{
  "vessels": {
    "self": {
      "uuid": "urn:mrn:signalk:uuid:${uuid}",
      "name": "OpenPlotter"
    }
  }
}
EOL

#autorun sk
install -m 644 files/signalk.service		"${ROOTFS_DIR}/etc/systemd/system/"
install -m 644 files/signalk.socket		"${ROOTFS_DIR}/etc/systemd/system/"
on_chroot << EOF
systemctl daemon-reload
systemctl enable signalk.service
systemctl enable signalk.socket
systemctl stop signalk.service
systemctl restart signalk.socket
systemctl restart signalk.service
EOF

#install sk plugins
on_chroot << EOF
cd /home/pi/.signalk
sudo -u pi npm i signalk-to-nmea2000
sudo -u pi npm i @signalk/signalk-node-red
sudo -u pi npm i @mxtommy/kip
sudo -u pi npm i @signalk/simulatorplugin
sudo -u pi npm i signalk-derived-data
sudo -u pi npm i signalk-to-influxdb
EOF

#config sk plugins
install -m 644 -o 1000 -g 1000 files/set-system-time.json		"${ROOTFS_DIR}/home/pi/.signalk/plugin-config-data/"
install -m 644 -o 1000 -g 1000 files/signalk-node-red.json	"${ROOTFS_DIR}/home/pi/.signalk/plugin-config-data/"
sed -i "s/credentialSecret: 'jkhdfshjkfdskjhfsjfsdkjhsfdjkfsd'/credentialSecret: false/g" "${ROOTFS_DIR}/home/pi/.signalk/node_modules/@signalk/signalk-node-red/index.js"

#install node-red nodes
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.signalk/red"
install -m 644 -o 1000 -g 1000 files/red/package.json	"${ROOTFS_DIR}/home/pi/.signalk/red/"

on_chroot << EOF
cd /home/pi/.signalk/red
sudo -u pi npm i node-red-dashboard
sudo -u pi npm i node-red-contrib-chatbot
sudo -u pi npm i node-red-contrib-msg-resend
sudo -u pi npm i node-red-contrib-usbcamera
EOF

#compile packages
on_chroot << EOF
cd /home/pi
if [ ! -d compiling ]; then
	mkdir compiling
fi
cd /home/pi/compiling

rm -rf canboat
git clone https://github.com/sailoog/canboat
cd canboat
make
make install

rm -rf /home/pi/compiling/
EOF
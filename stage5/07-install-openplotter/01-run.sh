#!/bin/bash -e

#install puthon packages
on_chroot << EOF
pip install pyudev pynmea2 websocket-client
EOF

#config MQTT server 
install -m 644 files/mosquitto.conf		"${ROOTFS_DIR}/etc/mosquitto/conf.d/"

#compile packages
on_chroot << EOF
cd /home/pi
if [ ! -d compiling ]; then
	mkdir compiling
fi
cd /home/pi/compiling

rm -rf kplex
git clone https://github.com/stripydog/kplex
cd kplex
make
make install

rm -rf /home/pi/compiling/
EOF


#install openplotter
on_chroot << EOF
cd /home/pi/.config
rm -rf openplotter
git clone -b v2.x.x https://github.com/sailoog/openplotter openplotter
EOF
chown -R 1000:1000 "${ROOTFS_DIR}/home/pi/.config/openplotter"
rm -rf "${ROOTFS_DIR}/home/pi/.config/openplotter/.git/"
chmod 775 "${ROOTFS_DIR}/home/pi/.config/openplotter/openplotter"
chmod 775 "${ROOTFS_DIR}/home/pi/.config/openplotter/startup"
echo "export PATH=$PATH:/home/pi/.config/openplotter" >> "${ROOTFS_DIR}/home/pi/.profile"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.config/autostart"
install -m 644 -o 1000 -g 1000 files/start_openplotter.desktop		"${ROOTFS_DIR}/home/pi/.config/autostart/"
install -m 644 files/OpenPlotter.directory		"${ROOTFS_DIR}/usr/share/raspi-ui-overrides/desktop-directories/"
install -m 644 -o 1000 -g 1000 files/openplotter.desktop		"${ROOTFS_DIR}/home/pi/.local/share/applications/"
install -m 644 -o 1000 -g 1000 files/openplotter_debug.desktop		"${ROOTFS_DIR}/home/pi/.local/share/applications/"
install -m 644 -o 1000 -g 1000 files/openplotter_help.desktop		"${ROOTFS_DIR}/home/pi/.local/share/applications/"
install -m 644 -o 1000 -g 1000 files/signalk.desktop		"${ROOTFS_DIR}/home/pi/.local/share/applications/"
install -m 644 -o 1000 -g 1000 files/signalk.ico		"${ROOTFS_DIR}/home/pi/.local/share/applications/"
install -m 644 files/xygrib.desktop		"${ROOTFS_DIR}/usr/share/applications/"
install -m 644 files/opencpn.desktop		"${ROOTFS_DIR}/usr/share/applications/"
install -m 644 files/lxde-pi-applications.menu		"${ROOTFS_DIR}/etc/xdg/menus/"
rm -f "${ROOTFS_DIR}/usr/share/raspi-ui-overrides/applications/raspi_getstart.desktop"
rm -f "${ROOTFS_DIR}/usr/share/raspi-ui-overrides/applications/help.desktop"
rm -f "${ROOTFS_DIR}/usr/share/raspi-ui-overrides/applications/raspi_resources.desktop"
rm -f "${ROOTFS_DIR}/usr/share/raspi-ui-overrides/applications/magpi.desktop"
#!/bin/bash -e

#start vnc server
on_chroot << EOF
systemctl enable vncserver-x11-serviced.service
EOF

#set hostapd conf
on_chroot << EOF
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' > /etc/default/hostapd
EOF

#add cron task
on_chroot << EOF
echo "@reboot /bin/bash /home/pi/.openplotter/start-ap-managed-wifi.sh" > /var/spool/cron/crontabs/root
chgrp crontab /var/spool/cron/crontabs/root
chmod 600 /var/spool/cron/crontabs/root
EOF

#copy files
install -m 644 files/dnsmasq.conf		"${ROOTFS_DIR}/etc/"
install -m 644 files/dhcpcd.conf		"${ROOTFS_DIR}/etc/"
install -m 644 files/sysctl.conf		"${ROOTFS_DIR}/etc/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.openplotter"
install -m 644 -o 1000 -g 1000 files/start-ap-managed-wifi.sh		"${ROOTFS_DIR}/home/pi/.openplotter/"
install -m 644 files/hostapd.conf		"${ROOTFS_DIR}/etc/hostapd/"
install -m 644 files/interfaces	"${ROOTFS_DIR}/etc/network/"
install -m 644 files/ap		"${ROOTFS_DIR}/etc/network/interfaces.d/"
install -m 644 files/station		"${ROOTFS_DIR}/etc/network/interfaces.d/"
install -m 644 files/72-static-name.rules		"${ROOTFS_DIR}/etc/udev/rules.d/"
install -m 644 files/11-openplotter-usb0.rules		"${ROOTFS_DIR}/etc/udev/rules.d/"
install -m 644 files/add_hostname_dot_local.sh		"${ROOTFS_DIR}/home/pi/"

if [ -e "${ROOTFS_DIR}/etc/udev/rules.d/90-wireless.rules" ]
then
    rm -f "${ROOTFS_DIR}/etc/udev/rules.d/90-wireless.rules"
fi

if [ -e "${ROOTFS_DIR}/lib/dhcpcd/dhcpcd-hooks/10-wpa_supplicant" ]
then
    mv "${ROOTFS_DIR}/lib/dhcpcd/dhcpcd-hooks/10-wpa_supplicant" "${ROOTFS_DIR}/lib/dhcpcd"
fi

on_chroot << EOF
erg=$(systemctl status dnsmasq | grep disabled)
chrlen=${#erg}
if [ $chrlen -gt 0 ]
then
	systemctl enable dnsmasq
fi

erg=$(systemctl status hostapd | grep disabled)
chrlen=${#erg}
if [ $chrlen -gt 0 ]
then
	systemctl enable hostapd
fi

cd /home/pi/
/bin/bash add_hostname_dot_local.sh
rm -f add_hostname_dot_local.sh
EOF

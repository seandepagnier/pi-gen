#!/bin/bash -e

on_chroot << EOF
wget "https://www.free-x.de/raspbian/xygrib/xygrib-maps_1.2.2-1_all.deb"
dpkg -i xygrib-maps_1.2.2-1_all.deb
rm -f xygrib-maps_1.2.2-1_all.deb
wget "https://www.free-x.de/raspbian/xygrib/xygrib_1.2.2-1_armhf.deb"
dpkg -i xygrib_1.2.2-1_armhf.deb
rm -f xygrib_1.2.2-1_armhf.deb
EOF

#!/bin/bash -e

#compile packages
on_chroot << EOF
cd /home/pi
if [ ! -d compiling ]; then
	mkdir compiling
fi

cd /home/pi/compiling
rm -rf RTIMULib2
git clone https://github.com/openplotter/RTIMULib2
cd RTIMULib2/Linux
mkdir build
cd build
cmake ..
make
make install
ldconfig
cd ..
cd python
python setup.py build
python setup.py install

cd /home/pi/compiling
rm -rf pypilot
rm -rf pypilot_data
git clone https://github.com/pypilot/pypilot
git clone https://github.com/pypilot/pypilot_data
cp -rv pypilot_data/* pypilot
cd pypilot
python setup.py build
python setup.py install

rm -rf /home/pi/compiling/
EOF

#config pypilot
install -m 644 files/gpsd		"${ROOTFS_DIR}/etc/default/"
install -m 644 files/gpsd.socket		"${ROOTFS_DIR}/lib/systemd/system/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.pypilot"
install -m 644 -o 1000 -g 1000 files/signalk.conf		"${ROOTFS_DIR}/home/pi/.pypilot/"
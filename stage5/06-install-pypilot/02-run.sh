#!/bin/bash -e

#compile packages
on_chroot << EOF
cd /home/pi
if [ ! -d compiling ]; then
	mkdir compiling
fi

cd /home/pi/compiling
rm -rf RTIMULib2-master
rm -f master.zip

wget "https://github.com/openplotter/RTIMULib2/archive/master.zip"
unzip master.zip
cd RTIMULib2-master/Linux
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
rm -rf pypilot-master
rm -rf pypilot_data-master
rm -f master.zip
rm -f master_data.zip

wget "https://github.com/pypilot/pypilot/archive/master.zip"
wget -O master_data.zip "https://github.com/pypilot/pypilot_data/archive/master.zip"
unzip master.zip
unzip master_data.zip
cp -rv pypilot_data-master/* pypilot-master
cd pypilot-master
python setup.py build
python setup.py install

rm -rf /home/pi/compiling/
EOF

#config pypilot
install -m 644 files/gpsd		"${ROOTFS_DIR}/etc/default/"
install -m 644 files/gpsd.socket		"${ROOTFS_DIR}/lib/systemd/system/"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.pypilot"
install -m 644 -o 1000 -g 1000 files/signalk.conf		"${ROOTFS_DIR}/home/pi/.pypilot/"
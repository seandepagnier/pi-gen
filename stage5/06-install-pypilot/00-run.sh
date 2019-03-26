#!/bin/bash -e

on_chroot << EOF
pip install pyglet ujson pyudev PyOpenGL PyWavefront
EOF

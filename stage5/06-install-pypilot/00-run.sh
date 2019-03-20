#!/bin/bash -e

on_chroot << EOF
pip install pyglet ujson PyOpenGL PyWavefront
EOF

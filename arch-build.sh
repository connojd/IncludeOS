#!/bin/bash

set -e

if [ ! -f install.sh ];
then
    echo -e "\e[31mERROR:\e[0m please run this from the includeos source"
    exit 22
fi

# Enable 32-bit libs
if [ ! -z $(grep '#\[multilib\]' /etc/pacman.conf) ];
then
    echo -e "\e[31mERROR:\e[0m please enable multilib in /etc/pacman.conf"
    exit 1
fi

# Install Arch dependencies
pacman -Syyu --noconfirm
pacman -S --needed --noconfirm \
    base-devel cmake curl nasm clang jq \
    bridge-utils qemu python2 python2-pip \
    python2-psutil python2-jsonschema lib32-gcc-libs

## Use python2
ln -sf /usr/bin/python2 /usr/bin/python
ln -sf /usr/bin/pip2 /usr/bin/pip
echo -e "\e[36mNOTICE:\e[0m created symlink /usr/bin/python -> /usr/bin/python2"
echo -e "\e[36mNOTICE:\e[0m created symlink /usr/bin/pip -> /usr/bin/pip2"

## Install python dependencies
pip install --upgrade pip
pip install junit-xml filemagic pystache antlr4-python2-runtime msgpack-python

# Create install directory
echo -n -e "\e[36mNOTICE:\e[0m"
echo ' created ${CMAKE_INSTALL_PREFIX}/includeos install directory'
mkdir -p $1/includeos

export INCLUDEOS_SRC=$(pwd)
export INCLUDEOS_PREFIX=$1

modprobe br_netfilter

./install.sh

#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

VERSION='task-2.4.4'
TAR="$VERSION-tar.gz"

wget http://taskwarrior.org/download/$TAR
tar -xvf $TAR
cd $VERSION
cmake -DCMAKE_BUILD_TYPE=release .
make
sudo make install

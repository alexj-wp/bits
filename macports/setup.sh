#!/bin/bash

# Grab my MacPorts repo so I can submit commits to it
REPO='git@github.com:alexj-wp/macports-ports.git'

# Set up paths
BASE_DIR="${HOME}/Projects/Code"
REPO_PATH="$BASE_DIR/macports-ports"
CONFIG="/opt/local/etc/macports/sources.conf"

# Grab the repo
cd $BASE_DIR
git clone $REPO

# Install gsed because macOS sed is bad
sudo port selfupdate
sudo port install gsed

# Add the repo to MacPorts itself
REPO_ENTRY="file://${REPO_PATH} [nosync]"
sudo gsed -i "/^rsync/i $REPO_ENTRY" $CONFIG
sudo port selfupdate

# Do an initial portindex.
echo "This is going to take a while..."
echo "Starting initial portindex of cloned repo."
echo "Expect this to take over 20 minutes."
sleep 3
cd $REPO_PATH
portindex

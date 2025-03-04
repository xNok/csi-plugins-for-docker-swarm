#!/bin/bash

USAGE="Usage: ./build.sh <Docker Hub Organization> <rclone CSI version>"

if [ "$1" == "--help" ] || [ "$#" -lt "2" ]; then
    echo $USAGE
    exit 0
fi

ORG=$1
VERSION=$2
VERSION_PLATFORM=$2${PLUGIN_PLATFORM:+"-$PLUGIN_PLATFORM"}

rm -rf rootfs
docker plugin disable csi-rclone:latest
docker plugin rm csi-rclone:latest
docker plugin disable $ORG/swarm-csi-rclone:$VERSION_PLATFORM
docker plugin rm $ORG/swarm-csi-rclone:$VERSION_PLATFORM
docker rm -vf rootfsimage

docker create --name rootfsimage wunderio/csi-rclone:$VERSION
mkdir -p rootfs
docker export rootfsimage | tar -x -C rootfs
docker rm -vf rootfsimage
cp entrypoint.sh rootfs/

docker plugin create $ORG/swarm-csi-rclone:$VERSION_PLATFORM .
docker plugin enable $ORG/swarm-csi-rclone:$VERSION_PLATFORM
docker plugin push $ORG/swarm-csi-rclone:$VERSION_PLATFORM
docker plugin disable $ORG/swarm-csi-rclone:$VERSION_PLATFORM
docker plugin rm $ORG/swarm-csi-rclone:$VERSION_PLATFORM
echo "Install Plugin"
docker plugin install \
    --alias csi-rclone \
    --grant-all-permissions \
    $ORG/swarm-csi-rclone:$VERSION_PLATFORM

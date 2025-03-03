#!/bin/bash

USAGE="Usage: ./build.sh <Docker Hub Organization> <rclone CSI version> <S3 provider> <S3 Endpoint> <s3 API Key ID> <S3 Secret Access Key>"

if [ "$1" == "--help" ] || [ "$#" -lt "6" ]; then
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
docker plugin install \
    --alias csi-rclone \
    --grant-all-permissions \
    $ORG/swarm-csi-rclone:$VERSION_PLATFORM \
    S3_PROVIDER=$3 \
    S3_ENDPOINT=$4 \
    S3_ACCESS_KEY_ID=$5 \
    S3_SECRET_ACCESS_KEY=$6

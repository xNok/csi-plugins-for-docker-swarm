#!/bin/sh
set -x

NODE_ID=$(cat /node_hostname)
/bin/csi-rclone-plugin \
  --nodeid=${NODE_ID} \
  --endpoint="unix:///run/docker/plugins/csi-rclone.sock"

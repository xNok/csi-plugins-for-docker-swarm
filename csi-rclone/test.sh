#!/bin/bash

# Create secrets
echo "minio-user" | docker secret create rclone-user - || true
echo "P@ssw0rd!" | docker secret create rclone-pwd - || true

# Create volume
docker volume create \
  --driver csi-rclone \
  --availability active \
  --scope single \
  --sharing none \
  --type mount \
  --opt remote=s3 \
  --opt remotePath=test \
  --opt s3-provider=minio \
  --opt s3-endpoint=http://minio.minio:9000 \
  --opt s3-access-key-id=minio-user \
  --opt s3-secret-access-key=P@ssw0rd! \
  my-csi-rclone-volume

# Verify that volume state is "created"
docker volume ls --cluster

# Create service
docker service rm my-service
docker service create \
  --name my-service \
  --mount type=cluster,src=my-csi-rclone-volume,dst=/usr/share/nginx/html \
  --publish 8081:80 \
  nginx
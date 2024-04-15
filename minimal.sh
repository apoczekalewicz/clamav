#!/usr/bin/env bash
set -o errexit

# Create a container
CONTAINER=$(buildah from scratch)

# Mount the container filesystem
MOUNTPOINT=$(buildah mount $CONTAINER)

# Install a basic filesystem and packages
dnf install -y --installroot $MOUNTPOINT  --releasever 39 --nodocs --setopt install_weak_deps=False glibc-minimal-langpack clamav clamav-freshclam ansible-core ansible-collection-ansible-posix ansible-collection-community-general mc 

dnf clean all -y --installroot $MOUNTPOINT --releasever 39

# entrypoint file
cp ./entrypoint.sh $MOUNTPOINT

cp -r ./antivirus $MOUNTPOINT 
chown -R 1000:0 $MOUNTPOINT/antivirus $MOUNTPOINT/etc/clamd.d
chmod -R g+rwX $MOUNTPOINT/antivirus $MOUNTPOINT/etc/clamd.d


# Network for freshclam command (update clamav database)
echo "nameserver 8.8.8.8" > $MOUNTPOINT/etc/resolv.conf

chroot $MOUNTPOINT freshclam

# Cleanup
buildah unmount $CONTAINER


# Non-root user 
buildah config --user 1000 $CONTAINER

# Command
buildah config --cmd "/bin/bash -c /entrypoint.sh" $CONTAINER

# HOME env (for mc)
buildah config --env HOME=/tmp $CONTAINER

# WORKING DIR
buildah config --workingdir /antivirus $CONTAINER

# Save the container to an image
buildah commit --squash $CONTAINER quay.io/apoczeka/clamav:latest

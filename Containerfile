#FROM quay.io/centoshyperscale/centos:stream9
FROM fedora-minimal
USER root
RUN 	microdnf --nodocs -y --setopt=install_weak_deps=False install clamav clamav-freshclam ansible-core ansible-collection-ansible-posix ansible-collection-community-general mc && \
	microdnf -y clean all 
RUN freshclam

COPY ./entrypoint.sh /entrypoint.sh
COPY ./antivirus /antivirus
RUN chown -R 1000:0 /antivirus && chmod -R g+rwX /antivirus


ENV HOME=/tmp
WORKDIR /antivirus
USER 1000

CMD ["/bin/bash", "-c", "/entrypoint.sh" ]


FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
ENV INSTALL_DIR /proton-install

RUN apt-get update && \
    apt upgrade -y && \
    apt-get install -y debsig-verify debian-keyring wget

RUN mkdir $INSTALL_DIR
ADD bridge.pol bridge_pubkey.gpg $INSTALL_DIR/
WORKDIR $INSTALL_DIR

# import public key into keyring
RUN mkdir -p /usr/share/debsig/keyrings/E2C75D68E6234B07 && \
    gpg --dearmor --output /usr/share/debsig/keyrings/E2C75D68E6234B07/debsig.gpg ./bridge_pubkey.gpg

# install the policy file
RUN mkdir -p /etc/debsig/policies/E2C75D68E6234B07 && \
    cp ./bridge.pol /etc/debsig/policies/E2C75D68E6234B07

# get and verify package
ENV VERIFIED_SUCCESS_MSG="debsig: Verified package from 'Proton Technologies AG (ProtonMail Bridge developers) <bridge@protonmail.ch>' (Proton Technologies AG)"
RUN wget https://protonmail.com/download/protonmail-bridge_1.1.3-1_amd64.deb
RUN debsig-verify ./protonmail-bridge_1.1.3-1_amd64.deb | grep "$VERIFIED_SUCCESS_MSG" || exit 1

# install 
RUN apt-get install -y ./protonmail-bridge_1.1.3-1_amd64.deb

# cleanup
RUN rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/protonmail-bridge", "--cli"]


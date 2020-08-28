FROM amd64/ros:foxy-ros-base-focal

LABEL mantainer="Paolo Tomasin <pooltomasin@hotmail.com>"
LABEL mantainer="Valerio Magnago <valerio.magnago@gmail.com>"

# run as root, let the entrypoint drop back to snail user
USER root

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV ROS_DISTRO foxy

# install packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    lsb-release \
    dirmngr \
    gnupg2 \
    clang \
    nano \
    curl \
    libasio-dev \
    libwiringpi-dev \
    libgps-dev \
    gpsd \
    gpsd-clients \
    fonts-powerline \
    libbluetooth-dev \
    xvfb
    

# Install ros2 pkg
RUN apt-get update && apt-get install -y \
    ros-${ROS_DISTRO}-demo-nodes-cpp \
    ros-${ROS_DISTRO}-demo-nodes-py \
    ros-${ROS_DISTRO}-diagnostic-msgs \
    ros-${ROS_DISTRO}-diagnostic-updater \
    ros-${ROS_DISTRO}-diagnostic-aggregator \
    ros-${ROS_DISTRO}-turtlesim
    

# setup ssh
RUN mkdir /var/run/sshd && \
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config


# add hostname
RUN echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
RUN echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
RUN echo "127.0.0.1   $HOSTNAME" >> /etc/hosts

# create std user named snail
RUN useradd --create-home -ms /bin/bash snail
RUN usermod -aG sudo snail

# entrypoint is used to update uid/gid and then run the users command
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/synth-shell/.bashrc /home/snail
COPY scripts/synth-shell/config /home/snail/.config/synth-shell

# set user passwords
RUN echo 'root:root' |chpasswd
RUN echo 'snail:snail' |chpasswd


# Unity https://gitlab.com/gableroux/unity3d#build-the-image 
RUN sudo apt-get update && sudo apt-get install -y \
	libgtk2.0-0 \
	libsoup2.4-1 \
	libarchive13 \
	libpng16-16 \
	libgconf-2-4 \
	lib32stdc++6 \
	libcanberra-gtk-module \
	libfuse2 \
	libnss3 \
	libasound2
RUN wget https://beta.unity3d.com/download/60781d942082/UnitySetup-2019.4.8f1 -O UnitySetup && \
    chmod +x UnitySetup && \
    echo y | ./UnitySetup \
        --unattended \
        --install-location=/opt/Unity \
        --verbose \
        --download-location=/tmp/unity \
        --components=Unity
RUN rm UnitySetup && \
    mkdir -p $HOME/.local/share/unity3d/Certificates/ && \
    sudo ln -s /opt/Unity/Editor/Unity /usr/bin/unity3d

RUN wget https://public-cdn.cloud.unity3d.com/hub/prod/UnityHub.AppImage -O /home/snail/UnityHub.AppImage && \
    chmod +x /home/snail/UnityHub.AppImage
    
RUN sudo apt-get update && sudo apt-get install -y \
	 nautilus \
	 libxss1
	 
RUN sudo chown snail:snail -R /home/snail/.config/

#USER snail
#RUN /home/snail/UnityHub.AppImage --no-sandbox --appimage-extract-and-run --headless install --version 2019.4.9f1 --module standardassets

# Cleanup
RUN apt-get -qq clean all && \
    rm -r -f /tmp/* && \
    rm -r -f /dockerFiles/* && \
    rm -r -f /var/tmp/* && \
    rm -r -f /var/lib/apt/lists/*

#ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /home/snail
CMD ["bash"]




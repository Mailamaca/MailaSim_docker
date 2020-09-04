FROM amd64/ubuntu:20.04

LABEL mantainer="Paolo Tomasin <pooltomasin@hotmail.com>"
LABEL mantainer="Valerio Magnago <valerio.magnago@gmail.com>"

#refs: https://index.ros.org/doc/ros2/Installation/Foxy/Linux-Development-Setup/ 
#refs: https://github.com/DynoRobotics/dyno-docker-images/blob/master/balena-amd64-ros2/dashing-isolated-cyclone/Dockerfile
#refs: https://github.com/samiamlabs/ros2_dotnet/blob/cyclone/Dockerfile

# environment vars
ENV ROS_DISTRO foxy
ENV ROS2_WS /opt/ros2_ws
ENV ROS_CMAKE_BUILD_TYPE Debug
ENV DOTNET_WS /opt/dotnet_ws

# setup timezone and environment
RUN apt-get update && apt-get install -qq -y \
    lsb-release \
    locales \
    curl \
    gnupg2 \
    tzdata
RUN echo 'Etc/UTC' > /etc/timezone
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

RUN locale-gen --purge en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# install utility packages
RUN apt-get update && apt-get install -qq -y \
  curl \
  wget \
  vim \
  less \
  net-tools \
  htop \
  can-utils \
  iputils-ping

# ROS2 ---------------------------------------------------------------------------
# setup ros2 keys
RUN curl http://repo.ros2.org/repos.key | apt-key add -
RUN curl -sL "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x5523BAEEB01FA116" | apt-key add

# setup sources.list
RUN echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list
#TODO: RUN echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

# install ROS2 dependencies
RUN apt-get update && apt-get install -qq -y \
  build-essential \
  cmake \
  git \
  python3-colcon-common-extensions \
  python3-pip \
  python3-rosdep \
  python3-vcstool \
  dirmngr \
  gnupg2 \
  libcunit1-dev

RUN python3 -m pip install -U \
  argcomplete \
  flake8 \
  flake8-blind-except \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  pytest-repeat \
  pytest-rerunfailures \
  pytest \
  pytest-cov \
  pytest-runner \
  setuptools \
  bash-completion

# clone source
RUN mkdir -p $ROS2_WS/src
WORKDIR $ROS2_WS
RUN wget https://raw.githubusercontent.com/ros2/ros2/$ROS_DISTRO/ros2.repos \
    && vcs import src < ros2.repos

# bootstrap rosdep
ENV ROSDISTRO_INDEX_URL https://raw.githubusercontent.com/ros/rosdistro/master/index.yaml
RUN rosdep init \
    && rosdep update

# install dependencies
RUN apt-get update && rosdep install -y \
    --from-paths src \
    --ignore-src \
    --rosdistro $ROS_DISTRO \
    --skip-keys "console_bridge fastcdr fastrtps libopensplice67 libopensplice69 rti-connext-dds-5.3.1 urdfdom_headers"

# NOTE(sam): rosdep hotfix...
#RUN rm -rf src && mkdir src
#COPY ros2.repos ros2.repos
#RUN vcs import src < ros2.repos
RUN apt-get update && apt-get install -qq -y \
    libasio-dev
    

# build source
WORKDIR $ROS2_WS
RUN colcon build --cmake-args -DCMAKE_BUILD_TYPE=$ROS_CMAKE_BUILD_TYPE

RUN echo "source ${ROS2_WS}/install/local_setup.bash" >> $HOME/.bashrc

# setup entrypoint
#COPY ./ros_entrypoint.sh /

# END OF ROS2

# ROS2 DOTNET -----------------------------------------------------------

# install dotnet build support
RUN bash -c '. /etc/os-release; wget -q https://packages.microsoft.com/config/${NAME,,}/${VERSION_ID,,}/packages-microsoft-prod.deb -O packages-microsoft-prod.deb'
RUN dpkg -i packages-microsoft-prod.deb

RUN apt-get update && apt-get install -qq -y \
  software-properties-common

RUN add-apt-repository universe

RUN apt-get update && apt-get install -qq -y \
  apt-transport-https \
  dotnet-sdk-3.1 \
  aspnetcore-runtime-3.1

# build 
RUN mkdir -p $DOTNET_WS/src
WORKDIR $DOTNET_WS
COPY ros2_dotnet.repos ros2_dotnet.repos
RUN vcs import src < ros2_dotnet.repos
#RUN rm -r src/dotnet/ros2_dotnet
#COPY . src/dotnet/ros2_dotnet

WORKDIR $DOTNET_WS
RUN bash -c ". ${ROS2_WS}/install/local_setup.bash; colcon build"
RUN bash -c ". ${ROS2_WS}/install/local_setup.bash; . ${DOTNET_WS}/install/local_setup.bash; ros2 run rcldotnet_utils create_unity_plugin"

RUN echo "source ${DOTNET_WS}/install/local_setup.bash" >> $HOME/.bashrc

#COPY ros_entrypoint.sh /

# END OF ROS2 DOTNET source /opt/ros2_ws/install/local_setup.bash

# UNITY3D -------------------------------------------------------------------------

ENV UNITYVERSION 2019.4.8f1

# Unity https://gitlab.com/gableroux/unity3d#build-the-image 
RUN apt-get update && apt-get install -qq -y \
	libgtk2.0-0 \
	libsoup2.4-1 \
	libarchive13 \
	libpng16-16 \
	libgconf-2-4 \
	lib32stdc++6 \
	libcanberra-gtk-module \
	libfuse2 \
	libnss3 \
	libasound2 \
	nautilus \
	libxss1 \
	libcwiid1 \
	libcwiid-dev
RUN wget https://beta.unity3d.com/download/60781d942082/UnitySetup-${UNITYVERSION} -O UnitySetup && \
    chmod +x UnitySetup

# create std user named snail
RUN useradd --create-home -ms /bin/bash snail
RUN usermod -aG sudo snail

# set user passwords
RUN echo 'root:root' |chpasswd
RUN echo 'snail:snail' |chpasswd

RUN apt-get update && apt-get install -qq -y \
    xz-utils
#RUN mkdir -p /opt/Unity-${UNITYVERSION}
RUN echo y | ./UnitySetup \
        --unattended \
        --install-location=/opt/Unity-${UNITYVERSION} \
        --verbose \
        --download-location=/tmp/unity \
        --components=Unity

RUN ln -s /opt/Unity-${UNITYVERSION}/Editor/Unity /usr/bin/unity3d
RUN rm UnitySetup

#unity3d license (https://github.com/wtanaka/docker-unity3d/blob/master/write_license_file.sh)
USER snail
RUN mkdir -p /home/snail/.cache/unity3d && \
    mkdir -p /home/snail/.local/share/unity3d/Unity && \
    mkdir -p /home/snail/.local/share/unity3d/Certificates
COPY --chown=snail:snail Unity_v2017.x.ulf /home/snail/.local/share/unity3d/Unity/Unity_lic.ulf


# unityhub (do not need it)
USER root
#RUN wget https://public-cdn.cloud.unity3d.com/hub/prod/UnityHub.AppImage -O /home/snail/UnityHub.AppImage && \
#    chmod +x /home/snail/UnityHub.AppImage

# END OF UNITY3D

# run as root, let the entrypoint drop back to snail user
USER root



# install packages
#RUN apt-get update -qq && apt-get install -qq -y \
#    openssh-server \
#    lsb-release \
#    dirmngr \
#    gnupg2 \
#    clang \
#    nano \
#    curl \
#    libasio-dev \
#    libwiringpi-dev \
#    libgps-dev \
#    gpsd \
#    gpsd-clients \
#    fonts-powerline \
#    libbluetooth-dev \
#    xvfb
    

# Install ros2 pkg
#RUN apt-get update -qq && apt-get install -qq -y \
#    ros-${ROS_DISTRO}-demo-nodes-cpp \
#    ros-${ROS_DISTRO}-demo-nodes-py \
#    ros-${ROS_DISTRO}-diagnostic-msgs \
#    ros-${ROS_DISTRO}-diagnostic-updater \
#    ros-${ROS_DISTRO}-diagnostic-aggregator \
#    ros-${ROS_DISTRO}-turtlesim
    

# setup ssh
#RUN mkdir /var/run/sshd && \
#    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
#    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config


# add hostname
RUN echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
RUN echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
RUN echo "127.0.0.1   $HOSTNAME" >> /etc/hosts

# create std user named snail
#RUN useradd --create-home -ms /bin/bash snail
#RUN usermod -aG sudo snail

# entrypoint is used to update uid/gid and then run the users command
USER snail
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/synth-shell/.bashrc /home/snail
COPY scripts/synth-shell/config /home/snail/.config/synth-shell

# set user passwords
#RUN echo 'root:root' |chpasswd
#RUN echo 'snail:snail' |chpasswd


USER root	 
RUN chown snail:snail -R /home/snail/.config/

#python 3.6
#RUN apt update && apt install -y \
#	software-properties-common && \
#    apt update && add-apt-repository -y \
#	ppa:deadsnakes/ppa && \
#    apt update && apt install -y \
#	python3.6 \
#	python3.6-dev
	
#libpocofoundation50
#RUN wget http://archive.ubuntu.com/ubuntu/pool/universe/p/poco/libpocofoundation50_1.8.0.1-1ubuntu4_amd64.deb
#RUN apt install -qq -y ./libpocofoundation50_1.8.0.1-1ubuntu4_amd64.deb
#RUN rm libpocofoundation50_1.8.0.1-1ubuntu4_amd64.deb

#.net
#RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
#RUN dpkg -i packages-microsoft-prod.deb
#RUN apt update && apt install -y \
# 	dotnet-sdk-3.1 && \
#	aspnetcore-runtime-3.1

#USER snail
#RUN /home/snail/UnityHub.AppImage --no-sandbox --appimage-extract-and-run --headless install --version 2019.4.9f1 --module standardassets

# Cleanup
RUN apt-get -qq clean all && \
    rm -r -f /tmp/* && \
    rm -r -f /dockerFiles/* && \
    rm -r -f /var/tmp/* && \
    rm -r -f /var/lib/apt/lists/*

#ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /
#RUN chown snail:snail -R /home/snail/.config/

#ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]




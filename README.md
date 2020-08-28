# MailaSim_docker
A repo containing a docker image for maila simulations

## Docker -  Development Environment

[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)
[![Open Source Love png2](https://badges.frapsoft.com/os/v2/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)

To ensure a common, consistent development environment we develop a docker image to run all the packages required from the *Maila* project.

## Content

This Docker Image contains the following:

* Ubuntu Focal Fossa 20.04
* ROS2 Foxy Fitzroy
* ...

## Installation

To get started, follow these steps:

### 1 Install docker
Install and configure [Docker](https://www.docker.com/get-started) for your operating system.

##### Windows

1. Install [Docker Desktop for Windows/Mac](https://www.docker.com/products/docker-desktop).

2. Right-click on the Docker task bar item, select **Settings/Preferences** and update **Resources > File Sharing** with any locations your source code is kept. See [tips and tricks](https://code.visualstudio.com/docs/remote/troubleshooting#_container-tips) for troubleshooting.

3. If you are using WSL 2 on Windows, to enable the [Windows WSL 2 back-end](https://aka.ms/vscode-remote/containers/docker-wsl2): Right-click on the Docker taskbar item and select **Settings**. Check **Use the WSL 2 based engine** and verify your distribution is enabled under **Resources > WSL Integration**.

##### Linux

1. Follow the [official install instructions for Docker CE/EE for your distribution](https://docs.docker.com/install/#supported-platforms). If you are using Docker Compose, follow the Docker Compose directions as well.

2. Add your user to the **docker** group by using a terminal to run: `sudo usermod -aG docker $USER`
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```

3. Sign out and back in again so your changes take effect.

### 2 Install Visaul Studio code
1 - Install [Visual Studio Code](https://code.visualstudio.com/) or [Visual Studio Code Insiders](https://code.visualstudio.com/insiders/).

2 - Install the [Remote Development extension pack](https://aka.ms/vscode-remote/download/extension).

## Settings (recommended)

Complete the following steps to create a new container:

1. **Clone or Download the Github Repository to your local Machine**

    ```bash
    git clone https://github.com/Mailamaca/Maila_docker.git
    ```

1. **Customize some settings to reflect your needs (optional)**
    You can change some Environment Variables directly in the [Dockerfile](https://github.com/Mailamaca/Maila_docker/blob/master/Dockerfile):

1. **Build the Docker Image**

    ```bash
    cd /path/to/MailaSim_docker
    docker build -t <your-docker-image-name> .
    # e.g
    cd MailaSim_docker
    docker build -t maila-sim-image .
    ```

    *Note: Please be sure to have enough disk space left. Building this image needs around 2GB of free space. The successfully built image has a size of 2GB*

1. **Run (create+start) Docker Container**
   
   
   - `--rm` Automatically remove the container when it exits
   - `-it` sets it as interactable and using stdin and stdout
   - `--name` sets the name of the container
   - `--h` sets the hostname of the container
   - `--mount` mount a volume, src=host/path, dst=container/path
   - `-v /tmp/.X11-unix:/tmp/.X11-unix` sets a volume to share the x server
   - `--env DISPLAY=$DISPLAY` sets an environment var for GUI
   - `-p` sets a port forwarding (for SSH e.g)

    Start as root:
    ``` bash
    docker run --rm -it \
        --name maila-container -h maila \
        --user 0 \
        --mount type=bind,src="$PWD"/../,dst=/mailamaca \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        --env DISPLAY=$DISPLAY \
        -p 2222:22 \
        maila-sim-image
    ```

    # need fuse for appimage (https://stackoverflow.com/questions/48402218/fuse-inside-docker)

    Start as user:
    ``` bash
    docker run --rm -it \
        --name maila-sim-container -h maila \
        --user "$(id -u):$(id -g)" \
        --mount type=bind,src="$PWD"/../,dst=/mailamaca \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        --env DISPLAY=$DISPLAY \
        -p 2222:22 \
        --device /dev/fuse \
        --cap-add SYS_ADMIN \
        --security-opt apparmor:unconfined \
        maila-sim-image
    ```

    ``` bash
    docker run --rm -it --privileged \
        --name maila-sim-container2 -h maila \
        --user 0 \
        --mount type=bind,src="$PWD"/../,dst=/mailamaca \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        --env DISPLAY=$DISPLAY \
        maila-sim-image
        
    ```
2. **run unityhub and unity inside container**

    ``` bash
    ./UnityHub.AppImage
    ```

    manual activation -> NEXT

    load file: mailamaca/Unity_v2017.x.ulf

    close

    ``` bash
    unity3d
    ```

    #### NOTE

    https://download.unity3d.com/download_unity/60781d942082/LinuxEditorInstaller/Unity.tar.xz

    https://gitlab.com/gableroux/unity3d#build-the-image 
    ``` bash
    
    sudo apt update && sudo apt install -y libgtk2.0-0 libsoup2.4-1 libarchive13 libpng16-16 libgconf-2-4 lib32stdc++6 libcanberra-gtk-module
    
    sudo apt update && sudo apt install -y libfuse2 libnss3 libasound2
    mkdir Download
    wget https://public-cdn.cloud.unity3d.com/hub/prod/UnityHub.AppImage
    sudo chmod +x UnityHub.AppImage
    sudo ./UnityHub.AppImage --appimage-extract-and-run --no-sandbox
    ```

    ``` bash
    sudo apt update && sudo apt install -y libgtk2.0-0 libsoup2.4-1 libarchive13 libpng16-16 libgconf-2-4 lib32stdc++6 libcanberra-gtk-module libglu1 libcanberra-gtk3-module
    sudo apt update && sudo apt install -y libglu1 libcanberra-gtk3-module
    mkdir Download
    wget https://beta.unity3d.com/download/dad990bf2728/UnitySetup-2018.2.7f1
    chmod +x UnitySetup-2018.2.7f1
    ./UnitySetup-2018.2.7f1
    ```

    ``` bash
    # unity link:
    # https://gitlab.com/gableroux/unity3d/-/blob/master/ci-generator/unity_versions.old.yml

    RUN wget https://beta.unity3d.com/download/60781d942082/UnitySetup-2019.4.8f1 && \
    chmod +x UnitySetup-2019.4.8f1 && \
    echo y | sudo ./UnitySetup-2019.4.8f1 --unattended --install-location=/opt/Unity-2019.4.8f1 --verbose --download-location=/tmp/unity --components=Unity && \
    rm UnitySetup-2019.4.8f1 && \
    mkdir -p $HOME/.local/share/unity3d/Certificates/ && \
    sudo ln -s /opt/Unity-2019.4.8f1/Editor/Unity /usr/bin/unity3d

    # symlink
    # sudo ln -s /opt/Unity-2019.4.8f1/Editor/Editor/Unity /usr/bin/unity3d

    #to run sudo gui application on the host terminal:
    xhost +local:docker

    sudo chown snail:snail -R ~/.config/
    /home/snail/UnityHub.AppImage --headless install --version 2019.4.9f1 --module standardassets

    sudo apt install flatpak
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install flathub com.unity.UnityHub
    flatpak run com.unity.UnityHub


    # python 3.6 (https://askubuntu.com/questions/1106603/how-to-co-install-libpython3-5-with-libpython3-6-and-libpython3-7) 

    RUN wget http://beta.unity3d.com/download/7807bc63c3ab/UnitySetup-2017.3.0p2 -O UnitySetup && \
    # make executable
    chmod +x UnitySetup-2020.1.2f1 && \
    # agree with license
    echo y | \
    # install unity with required components
    ./UnitySetup-2020.1.2f1 --unattended --install-location=/opt/Unity/Editor --verbose --download-location=/tmp/unity --components=Unity  && \
    # remove setup
    rm UnitySetup && \
    # make a directory for the certificate Unity needs to run
    mkdir -p $HOME/.local/share/unity3d/Certificates/

    # /opt/Unity/Editor/Unity
    # sudo ln -s /opt/Unity/Editor/Unity /usr/bin/unity3d
    ```


    this will be the main terminal windows, when this closes the container colses and all things made in it will be lost!

3. **Open a new terminal connected to the container (AS USER)**

    ``` bash
    docker exec -it maila-sim-container bash
    ```

4. **Open a new terminal connected to the container (AS ROOT)**

    ``` bash
    docker exec -u 0 -it maila-sim-container bash
    ```

## Visual Studio Code Remote extension

1. **Install ms-vscode-remote.remote-containers**

2. In the VSC console (F1) type "Remote-Containers: Open Folder in COntainer..." or click in the green square in the left-bottom part of VSC and select "Remote-Containers: Open Folder in COntainer..."

3. Select Maila_docker folder

4. Done! It will open the up-folder of Maila_docker inside the container

NOTE: the ```.devcontainer.json``` file contains all the information, it is quite the same as ```docker run``` 

## SSH

1. **With the container started open a new terminal connected to the container (AS ROOT)**

    ``` bash
    docker exec -u 0 -it maila-container /usr/sbin/sshd -d
    ```

2. **Access the Docker Container via SSH (in another host terminal):**

    ```bash
    ssh root@localhost -p 2222
    ```

    User | Password
    -------- | -----
    root | root

3. **if HOST IDENTIIFATION HAS CHANGED try this command**
   
   ```bash
    ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R "[localhost]:2222"
    ```

    then re-launch the ssh service in the previuous terminal and then re-try to login


## Docker useful commands

#### Remove container

1. Get all containers

   ``` bash
   docker ps -a
   ```

2. Delete ones

   ``` bash
   docker rm maila
   ```

#### Remove docker image

1. Get all images

   ``` bash
   docker images
   ```

2. Delete ones

   ``` bash
   docker rmi 27aba35ee129
   ```

3. Delete dangling images (https://www.projectatomic.io/blog/2015/07/what-are-docker-none-none-images/)

   ``` bash
   docker rmi $(docker images -f "dangling=true" -q)
   ```

#### Start/Stop of Docker Container

    ```bash
    docker start -ia <your-docker-container-name>
    docker stop <your-docker-container-name>
    # e.g
    docker start -ia maila-container
    docker stop maila-container
    ```


#### Backup container state (NOT THE DATA VOLUME)

1. Create a backup of the container to an image. 

   ``` bash
   docker commit -p maila maila/backup:20200720
   ```

   Kindly note that this will not cover the data volume. You need to take the backup of data-volume (if any) separately. To know this data-directory (data volume location) of a container, use the command `docker inspect container-name`. You will get a section called “Mounts”. Location mentioned in “Source” is the data volume. You may directly backup this folder(here /site) to get backup of data volume.

2. Save image as a tar file

   ``` bash
   docker save -o maila_backup_20200720.tar maila/backup:20200720
   ```

#### Restore container backup (NOT THE DATA VOLUME)

1. Image can be extracted from backup tar file using the following command

   ``` bash
   docker load -i /tmp/backup01.tar
   ```

2. You can create container from this image using “docker create“. If you had data volume on the original container. You must restore the data volume too and run container with the data volume (docker create -v)



#### Check the version of Docker installed on your machine

<code>    <span class="nv">$ </span>docker --version<span class="nt">--all</span> </code>

####  Download and start a session with ROS2 foxy docker container

<code>    <span class="nv">$ </span>docker run -it ros:foxy <span class="nt">--all</span> </code>

####  List of the images downloaded to your machine

<code>    <span class="nv">$ </span>docker image ls <span class="nt">--all</span>

    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    ros                 foxy                4273086f549d        13 days ago         722MB
</code>

####  run a docker image

<code>    <span class="nv">$ </span>docker run <image ID> <span class="nt">--all</span> </code>

####  List all containers (spawned by the image) that exit after displaying its message.

If it is still running, you do not need the **--all** option

<code>    <span class="nv">$ </span>docker ps --all <span class="nt">--all</span>

    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                     PORTS               NAMES
    9867db35d3fe        4273086f549d        "/ros_entrypoint.sh …"   8 minutes ago       Exited (0) 8 minutes ago                       priceless_goldberg
    42f7c2645a99        ros:foxy            "/ros_entrypoint.sh …"   16 minutes ago      Up 15 minutes                                  competent_feynman
</code>

## ROS2 turtlesim example

``` bash
source /opt/ros/foxy/setup.bash
printenv | grep -i ROS
apt update
apt install ros-foxy-turtlesim
ros2 pkg executables turtlesim
ros2 run turtlesim turtlesim_node
ros2 run turtlesim turtle_teleop_key
```

## Credits
This Dockerfile is based on the following work:

-  Daniel Hochleitner's GitHub Project [ Dani3lSun/docker-db-apex-dev](https://github.com/Dani3lSun/docker-db-apex-dev)

- https://tuw-cpsg.github.io/tutorials/docker-ros/

## License

MIT

See [Oracle Database Licensing Information User Manual](https://docs.oracle.com/database/122/DBLIC/Licensing-Information.htm#DBLIC-GUID-B6113390-9586-46D7-9008-DCC9EDA45AB4) regarding Oracle Database licenses.


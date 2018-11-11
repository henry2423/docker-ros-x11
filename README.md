# Docker container images with ROS, Gazebo, X11 windows and Tensorflow capability
This repository developed from nvidia/opengl and nvidia/cuda conatiners, combine these two together to create a ROS develope environment in docker

## Current Image Build:
* `henry2423/ros-x11-ubuntu:melodic` : __Ubuntu 16.04 with `ROS melodic + Gazebo 9`__

  [![](https://images.microbadger.com/badges/version/henry2423/ros-x11-ubuntu:melodic.svg)](https://hub.docker.com/r/henry2423/ros-x11-ubuntu/) [![](https://images.microbadger.com/badges/image/henry2423/ros-x11-ubuntu:melodic.svg)](https://microbadger.com/images/henry2423/ros-x11-ubuntu:melodic)

* `henry2423/ros-x11-ubuntu:kinetic` : __Ubuntu 16.04 with `ROS Kinetic + Gazebo 8`__

  [![](https://images.microbadger.com/badges/version/henry2423/ros-x11-ubuntu:kinetic.svg)](https://hub.docker.com/r/henry2423/ros-x11-ubuntu/) [![](https://images.microbadger.com/badges/image/henry2423/ros-x11-ubuntu:kinetic.svg)](https://microbadger.com/images/henry2423/ros-x11-ubuntu:kinetic)

## Requirement
* Docker and Nvidia-docker(docker nvidia runtime) on the host: Check with [NVIDIA/nvidia-docker](https://github.com/NVIDIA/nvidia-docker)
* X11 Server install:

      $ apt-get install xauth xorg openbox

## Usage
- For the first time before runing up the docker, you should setup X11 socket and X11 auth files by runing command:

      XSOCK=/tmp/.X11-unix
      XAUTH=/tmp/.docker.xauth
      touch $XAUTH
      xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

- Run command with x11 configuration, to set up the display environment:

      nvidia-docker run -it \
        --volume /tmp/.X11-unix:/tmp/.X11-unix:rw \
        --volume /tmp/.docker.xauth:/tmp/.docker.xauth:rw \
        --env "XAUTHORITY=/tmp/.docker.xauth" \
        --env "DISPLAY" \
        --volume /etc/passwd:/etc/passwd \
        --volume /etc/group:/etc/group \
        --user $(id -u):$(id -g) \
        henry2423/ros-x11-ubuntu:kinetic \
        bash

- If you want to connect to tensorboard, run command with mapping to local port `6006`:
      
      nvidia-docker run -it \
        -p 6006:6006 \
        --volume /tmp/.X11-unix:/tmp/.X11-unix:rw \
        --volume /tmp/.docker.xauth:/tmp/.docker.xauth:rw \
        --env "XAUTHORITY=/tmp/.docker.xauth" \
        --env "DISPLAY" \
        --volume /etc/passwd:/etc/passwd \
        --volume /etc/group:/etc/group \
        --volume /etc/shadow:/etc/shadow \
        --user $(id -u):$(id -g) \
        henry2423/ros-x11-ubuntu:kinetic \
        bash

- Build an image from scratch:

      docker build -t henry2423/ros-x11-ubuntu .

## Connect & Control
If the container runs up, you can connect to the container throught the following
* You can open the GUI program directly, such as rviz and gazebo 
* Connect to __Tensorboard__ if you do the tensorboard mapping above: [`http://localhost:6006`](http://localhost:6006)
* The username and password in container is same as your host account



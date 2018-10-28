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